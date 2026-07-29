from __future__ import annotations

import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[2]
FORK_SCRIPT = ROOT / "scripts" / "fork_chrome_profile.sh"


class ProfileForkTest(unittest.TestCase):
    def test_creates_independent_lean_snapshot(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            base = Path(temp_dir)
            source = base / "source"
            target = base / "target"

            (source / "Default" / "Extensions").mkdir(parents=True)
            (source / "Default" / "Cache").mkdir(parents=True)
            (source / "OptGuideOnDeviceModel").mkdir()
            (source / "Default" / "Preferences").write_text("preferences", encoding="utf-8")
            (source / "Default" / "Extensions" / "state").write_text("extension", encoding="utf-8")
            (source / "Default" / "Cache" / "entry").write_text("cache", encoding="utf-8")
            (source / "OptGuideOnDeviceModel" / "model").write_text("model", encoding="utf-8")
            (source / "SingletonLock").symlink_to("/tmp/source-singleton")

            result = subprocess.run(
                [str(FORK_SCRIPT), "--source", str(source), "--target", str(target)],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(
                (target / "Default" / "Preferences").read_text(encoding="utf-8"),
                "preferences",
            )
            self.assertTrue((target / "Default" / "Extensions" / "state").is_file())
            self.assertFalse((target / "Default" / "Cache").exists())
            self.assertFalse((target / "OptGuideOnDeviceModel").exists())
            self.assertFalse((target / "SingletonLock").exists())
            self.assertIn("mode=lean-independent-snapshot", (target / ".aginti-profile-fork").read_text())

    def test_refuses_existing_target(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            base = Path(temp_dir)
            source = base / "source"
            target = base / "target"
            source.mkdir()
            target.mkdir()

            result = subprocess.run(
                [str(FORK_SCRIPT), "--source", str(source), "--target", str(target)],
                text=True,
                capture_output=True,
                check=False,
            )

            self.assertEqual(result.returncode, 5)
            self.assertIn("refusing to merge or overwrite", result.stderr)


if __name__ == "__main__":
    unittest.main()
