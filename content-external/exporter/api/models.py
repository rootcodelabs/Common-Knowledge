"""Pydantic models for the API boundary only.

Plain dataclasses are the house style everywhere under core/ (B2); pydantic
stays at the edge, which is here.

Contract rule for /health: ADDITIVE ONLY. Every field A15 or a later stage
adds must be optional with a default, so an alert rule or a probe written
against today's response keeps working. Nothing here is ever removed or
retyped.
"""

from typing import Literal

from pydantic import BaseModel


class LastRunSummary(BaseModel):
    """The last terminal run this process saw.

    Written by A15; None until a run completes, which is honest rather than
    optimistic — an hourly job that has never run is not the same as one that
    ran and succeeded. Defined now, while it is always None, so A15's diff to
    this file is zero and the OpenAPI schema published on day one is final.
    """

    outcome: Literal["success", "unchanged", "busy", "failed"]
    run_id: str
    agency_id: str
    finished_at: str
    duration_seconds: float


class HealthResponse(BaseModel):
    """Liveness plus configuration identity.

    Deliberately excluded: external_s3_endpoint_url, any bucket or container
    name, llm_module_base_url, anything from Vault. /health is unauthenticated
    on bykstack. The fields below are the ones content-external/README.md
    already promises an operator ("Check CONTENT_SINK ... or GET /health"),
    and none of them identifies a destination.
    """

    status: Literal["ok"]
    sink: str
    store_backend: str
    chunk_profile: str
    work_dir: str
    last_run: LastRunSummary | None = None
