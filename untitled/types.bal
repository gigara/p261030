public type OrderItem record {|
    string productId;
    int quantity;
    decimal unitPrice;
|};

public type NewOrder record {|
    string customerName;
    OrderItem[] items;
|};

public type Order record {|
    string id;
    string customerName;
    OrderItem[] items;
    decimal totalAmount;
    string createdAt;
|};
