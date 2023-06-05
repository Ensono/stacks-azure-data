# Logging configuration
import logging
import colorlog


def setup_logger(name: str = "", log_level: int = logging.INFO):
    formatter = colorlog.ColoredFormatter(
        fmt="%(log_color)s%(asctime)s %(levelname)s%(reset)s%(blue)s %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
        reset=True,
        log_colors={
            "DEBUG": "cyan",
            "INFO": "green",
            "WARNING": "yellow",
            "ERROR": "red",
            "CRITICAL": "red,bg_white",
        },
        secondary_log_colors={},
        style="%",
    )

    handler = colorlog.StreamHandler()
    handler.setFormatter(formatter)

    logger = colorlog.getLogger(name)
    logger.addHandler(handler)
    logger.setLevel(log_level)

    return logger
