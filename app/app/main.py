"""Sample service shipped by the blue/green pipeline.

It is deliberately small: the interesting part of this repository is how it is
released, not what it does. The endpoints exist so the deploy tooling has
something meaningful to probe:

* ``/health``  - liveness/readiness probe used before traffic is switched.
* ``/version`` - reports the image tag and colour that is serving the request,
  which makes it easy to watch a switch happen from the outside.
"""

from __future__ import annotations

import os
import platform
import time
from dataclasses import dataclass

from fastapi import FastAPI, Response, status


@dataclass(frozen=True)
class Settings:
    version: str
    color: str
    fail_health: bool

    @classmethod
    def from_env(cls) -> "Settings":
        return cls(
            version=os.getenv("APP_VERSION", "dev"),
            color=os.getenv("APP_COLOR", "none"),
            # Lets you rehearse a failed release: a container started with
            # APP_FAIL_HEALTH=1 never becomes healthy, so the deploy must abort
            # without ever routing traffic to it.
            fail_health=os.getenv("APP_FAIL_HEALTH", "0").lower() in {"1", "true", "yes"},
        )


def create_app(settings: Settings | None = None) -> FastAPI:
    cfg = settings or Settings.from_env()
    started_at = time.monotonic()

    api = FastAPI(title="zero-downtime-iac sample app", version=cfg.version)

    @api.get("/")
    def index() -> dict[str, str]:
        return {
            "message": "Hello from the zero-downtime-iac sample app",
            "version": cfg.version,
            "color": cfg.color,
        }

    @api.get("/health")
    def health(response: Response) -> dict[str, object]:
        if cfg.fail_health:
            response.status_code = status.HTTP_503_SERVICE_UNAVAILABLE
            return {"status": "failing", "reason": "APP_FAIL_HEALTH is set"}
        return {"status": "ok", "uptime_seconds": round(time.monotonic() - started_at, 3)}

    @api.get("/version")
    def version() -> dict[str, str]:
        return {
            "version": cfg.version,
            "color": cfg.color,
            "python": platform.python_version(),
        }

    return api


app = create_app()
