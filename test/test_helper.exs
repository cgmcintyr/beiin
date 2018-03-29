Application.ensure_all_started(:mox)
Mox.defmock(KairosDatabase.MockRequest, for: KairosDatabase.Request)
ExUnit.start()
