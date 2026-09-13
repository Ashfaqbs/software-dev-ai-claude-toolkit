---
name: kafka-patterns
description: Spring Kafka producer/consumer patterns, idempotent consumers, dead letter topics, and manual offset commits. Use when producing to or consuming from Kafka topics in a Spring Boot service.
---

# Kafka Patterns (Spring Kafka)

Concrete implementations of the conventions in `rules/infra.md`: topic naming, manual commits, idempotent consumers, and dead letter topics.

## When to Activate

- Adding a `@KafkaListener` consumer or a `KafkaTemplate` producer
- Designing a new topic or partition key
- Handling consumer failures without losing or duplicating messages
- Setting up a dead letter topic for a consumer group

## Producer

```java
@Service
public class OrderEventProducer {
    private final KafkaTemplate<String, OrderCancelledEvent> kafkaTemplate;

    public OrderEventProducer(KafkaTemplate<String, OrderCancelledEvent> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void publishCancelled(Order order) {
        // Partition key = orderId keeps every event for one order in the same
        // partition, so a consumer sees them in order.
        String topic = "orders.order.cancelled";
        OrderCancelledEvent event = OrderCancelledEvent.from(order);

        kafkaTemplate.send(topic, order.getId().toString(), event)
            .whenComplete((result, ex) -> {
                if (ex != null) {
                    log.error("Failed to publish {} for order {}", topic, order.getId(), ex);
                }
            });
    }
}
```

## Consumer with Manual Commit + Idempotency

```java
@Component
public class OrderCancelledConsumer {
    private final ProcessedEventRepository processedEvents;
    private final InventoryService inventoryService;

    public OrderCancelledConsumer(ProcessedEventRepository processedEvents, InventoryService inventoryService) {
        this.processedEvents = processedEvents;
        this.inventoryService = inventoryService;
    }

    @KafkaListener(topics = "orders.order.cancelled", groupId = "inventory-service")
    public void handle(ConsumerRecord<String, OrderCancelledEvent> record, Acknowledgment ack) {
        String eventId = record.key() + ":" + record.offset();

        // Idempotency guard: at-least-once delivery means this handler can run
        // more than once for the same record. Check-then-insert on a unique
        // constraint, not a plain SELECT, to survive concurrent redelivery.
        if (processedEvents.existsById(eventId)) {
            ack.acknowledge();
            return;
        }

        try {
            inventoryService.rollback(record.value().orderId());
            processedEvents.save(new ProcessedEvent(eventId, Instant.now()));
            ack.acknowledge();
        } catch (Exception ex) {
            log.error("Failed to process cancellation for order {}", record.value().orderId(), ex);
            // Do not acknowledge — the record will be redelivered. A retry
            // policy + dead letter topic (below) bounds how many times.
        }
    }
}
```

```yaml
# application.yml — manual commit, no auto-commit
spring:
  kafka:
    consumer:
      enable-auto-commit: false
      auto-offset-reset: earliest
    listener:
      ack-mode: manual
```

## Dead Letter Topic

```java
@Bean
public DefaultErrorHandler errorHandler(KafkaTemplate<Object, Object> kafkaTemplate) {
    var recoverer = new DeadLetterPublishingRecoverer(kafkaTemplate,
        (record, ex) -> new TopicPartition(record.topic() + ".dlt", record.partition()));

    // 3 retries with backoff, then publish to <topic>.dlt instead of blocking
    // the partition forever on a poison message.
    return new DefaultErrorHandler(recoverer, new FixedBackOff(1000L, 3));
}
```

## Topic Naming and Partition Keys

| Concern | Convention | Example |
|---|---|---|
| Topic name | `<domain>.<entity>.<event>` | `orders.order.cancelled` |
| Partition key | Field that must preserve order | `orderId`, `userId` |
| Consumer group | One per logical consumer | `inventory-service`, `notification-service` |
| Dead letter topic | `<topic>.dlt` | `orders.order.cancelled.dlt` |

## Anti-Patterns

- **Auto-commit with business logic in the listener** — a crash between poll and processing silently drops the message. Use manual `Acknowledgment`.
- **No idempotency check** — Kafka is at-least-once; the same record WILL be redelivered after a rebalance or retry. Every consumer must tolerate duplicates.
- **JSON without a schema** — fine for prototyping, but breaks silently on producer/consumer version drift in production. Prefer Avro/Protobuf with Schema Registry per `rules/infra.md`.
- **One giant topic for every event type** — makes consumer group scaling and retention policy impossible to tune per event. Split by domain/entity.

## Related

- Rule: `infra.md` — Kafka/Flink conventions this skill implements
- Rule: `java-springboot.md` — `@KafkaListener`/`KafkaTemplate` usage
