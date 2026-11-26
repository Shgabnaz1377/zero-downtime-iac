from fastapi.testclient import TestClient

from app.main import Settings, create_app


def client(**overrides: object) -> TestClient:
    base = {"version": "1.2.3", "color": "blue", "fail_health": False}
    base.update(overrides)
    return TestClient(create_app(Settings(**base)))  # type: ignore[arg-type]


def test_health_ok() -> None:
    response = client().get("/health")
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "ok"
    assert body["uptime_seconds"] >= 0


def test_health_can_be_forced_to_fail() -> None:
    response = client(fail_health=True).get("/health")
    assert response.status_code == 503
    assert response.json()["status"] == "failing"


def test_version_reports_tag_and_color() -> None:
    response = client(version="2026.11.26", color="green").get("/version")
    assert response.status_code == 200
    body = response.json()
    assert body["version"] == "2026.11.26"
    assert body["color"] == "green"
    assert body["python"]


def test_index_mentions_color() -> None:
    body = client(color="green").get("/").json()
    assert body["color"] == "green"
    assert body["version"] == "1.2.3"


def test_settings_from_env(monkeypatch) -> None:
    monkeypatch.setenv("APP_VERSION", "9.9.9")
    monkeypatch.setenv("APP_COLOR", "blue")
    monkeypatch.setenv("APP_FAIL_HEALTH", "true")
    cfg = Settings.from_env()
    assert cfg == Settings(version="9.9.9", color="blue", fail_health=True)


def test_settings_defaults(monkeypatch) -> None:
    for name in ("APP_VERSION", "APP_COLOR", "APP_FAIL_HEALTH"):
        monkeypatch.delenv(name, raising=False)
    cfg = Settings.from_env()
    assert cfg == Settings(version="dev", color="none", fail_health=False)
