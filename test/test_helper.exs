Application.ensure_all_started(:mox)
Mox.defmock(Beiin.DB.Kairos.Request.Mock, for: Beiin.DB.Kairos.Request)
ExUnit.start()
