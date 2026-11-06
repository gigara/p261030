import ballerina/http;
import ballerina/time;
import ballerina/uuid;

isolated map<Order> orders = {};

service / on new http:Listener(8080) {

    resource function post orders(@http:Payload NewOrder newOrder) returns Order|http:BadRequest {
        if newOrder.items.length() == 0 {
            return <http:BadRequest>{
                body: {message: "Order must contain at least one item"}
            };
        }

        decimal totalAmount = 0;
        foreach OrderItem item in newOrder.items {
            if item.quantity <= 0 {
                return <http:BadRequest>{
                    body: {message: "Item quantity must be greater than zero"}
                };
            }
            totalAmount += item.unitPrice * <decimal>item.quantity;
        }

        string orderId = uuid:createType1AsString();
        string createdAt = time:utcToString(time:utcNow());

        Order newOrderRecord = {
            id: orderId,
            customerName: newOrder.customerName,
            items: newOrder.items,
            totalAmount: totalAmount,
            createdAt: createdAt
        };

        lock {
            orders[orderId] = newOrderRecord.clone();
        }

        return newOrderRecord;
    }

    resource function get orders() returns json {
        lock {
            return orders.toArray().clone().toJson();
        }
    }

    resource function delete orders/[string orderId]() returns http:Ok|http:NotFound {
        lock {
            if !orders.hasKey(orderId) {
                return <http:NotFound>{
                    body: {message: string `Order not found: ${orderId}`}
                };
            }
            _ = orders.remove(orderId);
        }
        return <http:Ok>{
            body: {message: "Order deleted successfully"}
        };
    }
}
