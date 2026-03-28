# Testing Anti-Patterns

Load this reference when writing or changing tests, adding mocks, or tempted to add test-only methods to production code.

## Core Principle

Test what the code does, not what the mocks do. Mocks are a means to isolate, not the thing being tested.

## The Iron Laws

1. NEVER test mock behavior
2. NEVER add test-only methods to production classes
3. NEVER mock without understanding dependencies

## Anti-Pattern 1: Testing Mock Behavior

```python
# BAD: testing that the mock exists
def test_processes_data(mocker):
    mock_service = mocker.patch("app.service.DataService")
    result = process(mock_service)
    assert mock_service.called  # proves nothing about real behavior

# GOOD: test real behavior
def test_processes_data(data_service):
    result = process(data_service)
    assert result.status == "complete"
    assert result.records_processed == 5
```

**Gate:** Before asserting on any mock, ask "Am I testing real behavior or mock existence?" If mock existence, delete the assertion.

## Anti-Pattern 2: Test-Only Methods in Production

```python
# BAD: destroy() only used in tests
class Session:
    def destroy(self):  # test-only!
        self._cleanup_resources()

# GOOD: test utilities handle cleanup
# in conftest.py or test_utils.py
def cleanup_session(session: Session) -> None:
    workspace = session.get_workspace_info()
    if workspace:
        workspace_manager.destroy(workspace.id)
```

**Gate:** Before adding any method to a production class, ask "Is this only used by tests?" If yes, put it in test utilities.

## Anti-Pattern 3: Mocking Without Understanding

```python
# BAD: mock prevents side effect the test depends on
def test_detects_duplicate(mocker):
    mocker.patch("app.config.write_config")  # breaks duplicate detection!
    add_server(config)
    add_server(config)  # should raise, but won't

# GOOD: mock at the correct level
def test_detects_duplicate(mocker):
    mocker.patch("app.server.start_server")  # mock the slow part only
    add_server(config)  # config written
    with pytest.raises(DuplicateServerError):
        add_server(config)  # duplicate detected
```

**Gate:** Before mocking, ask:
1. What side effects does the real method have?
2. Does this test depend on any of those side effects?
3. If yes, mock at a lower level that preserves the needed behavior.

## Anti-Pattern 4: Incomplete Mocks

```python
# BAD: partial mock missing fields downstream code uses
mock_response = {"status": "success", "data": {"user_id": "123"}}
# later: KeyError on response["metadata"]["request_id"]

# GOOD: mirror real API completeness
mock_response = {
    "status": "success",
    "data": {"user_id": "123", "name": "Alice"},
    "metadata": {"request_id": "req-789", "timestamp": 1234567890},
}
```

**Gate:** Before creating mock responses, check what the real API returns. Include all fields the system might consume downstream.

## Anti-Pattern 5: Tests as Afterthought

TDD prevents this entirely. If you write implementation first, you cannot claim it is complete. The cycle is: failing test, implementation, refactor, then done.

## When Mocks Become Too Complex

Warning signs:
- Mock setup is longer than test logic
- Mocking everything to make the test pass
- Test breaks when mock changes but production works fine

When this happens, consider integration tests with real components — they are often simpler than complex mock setups.

## Quick Reference

| Anti-Pattern | Fix |
|---|---|
| Assert on mock elements | Test real behavior or unmock it |
| Test-only methods in production | Move to test utilities |
| Mock without understanding | Understand dependencies first, mock minimally |
| Incomplete mocks | Mirror real API completely |
| Tests as afterthought | TDD — tests first |
| Over-complex mocks | Consider integration tests |

## Red Flags

- Assertions checking mock call counts without verifying outcomes
- Methods only called in test files
- Mock setup is >50% of the test
- Test fails when you remove the mock
- Cannot explain why a mock is needed
- Mocking "just to be safe"
