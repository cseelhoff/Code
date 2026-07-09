# When to Mock

Mock at **system boundaries** only:

- External APIs (payment, email, etc.)
- Databases (sometimes - prefer test DB)
- Time/randomness
- File system (sometimes)

Don't mock:

- Your own modules / free functions
- Internal collaborators
- Anything you control

## Designing for Mockability

At system boundaries, design **public surfaces** that are easy to fake — plain data in/out and explicit collaborator parameters (function values or small ops tables), not class hierarchies.

**1. Pass dependencies as parameters**

Pass external collaborators in rather than constructing them internally:

```typescript
// Easy to mock — collaborator is an argument
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to mock — constructs the real backend inside
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. Prefer SDK-style ops over generic fetchers**

Create specific functions for each external operation instead of one generic function with conditional logic:

```typescript
// GOOD: Each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: Mocking requires conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

The SDK approach means:
- Each mock returns one specific shape
- No conditional logic in test setup
- Easier to see which endpoints a test exercises
- Type safety per endpoint
