import sys
import os

# Add src to sys.path
sys.path.append(os.getcwd())

from src.app.core.logging import configure_logging, get_logger
from src.app.core.config import get_settings

try:
    configure_logging()
    logger = get_logger("test_logger")
    settings = get_settings()
    logger.info("test_event", environment=settings.environment, version=settings.app_version)
    print("SUCCESS: Logging configured and test event emitted.")
except Exception as e:
    print(f"FAILURE: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
