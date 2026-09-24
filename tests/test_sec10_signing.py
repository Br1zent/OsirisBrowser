import importlib.util
import hashlib
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("osiris_build", ROOT / "build.py")
build = importlib.util.module_from_spec(spec)
spec.loader.exec_module(build)
OFFICIAL_WRAPPER_JAR_SHA256 = "d3b261c2820e9e3d8d639ed084900f11f4a86050a8f83342ade7b6bc9b0d2bdd"


class ReleaseSigningTests(unittest.TestCase):
    def test_release_without_secrets_fails_closed(self):
        with self.assertRaisesRegex(ValueError, "ANDROID_KEYSTORE_PATH"):
            build.validate_android_release_signing({})

    def test_missing_keystore_file_fails_closed(self):
        env = {
            "ANDROID_KEYSTORE_PATH": "/not/a/real/keystore.jks",
            "ANDROID_KEY_ALIAS": "release",
            "ANDROID_STORE_PASSWORD": "test-only-canary",
            "ANDROID_KEY_PASSWORD": "test-only-canary",
        }
        with self.assertRaisesRegex(ValueError, "existing keystore"):
            build.validate_android_release_signing(env)

    def test_release_accepts_complete_external_configuration(self):
        with tempfile.NamedTemporaryFile() as keystore:
            env = {
                "ANDROID_KEYSTORE_PATH": keystore.name,
                "ANDROID_KEY_ALIAS": "release",
                "ANDROID_STORE_PASSWORD": "test-only-canary",
                "ANDROID_KEY_PASSWORD": "test-only-canary",
            }
            self.assertIsNone(build.validate_android_release_signing(env))

    def test_tracked_signing_config_has_no_embedded_passwords(self):
        gradle = (ROOT / "android/app/build.gradle").read_text()
        script = (ROOT / "build.py").read_text()
        self.assertNotRegex(gradle, r"(?m)^\s*(?:keyPassword|storePassword)\s+['\"]")
        self.assertNotIn("store_password", script)
        self.assertIn("System.getenv('ANDROID_STORE_PASSWORD')", gradle)
        self.assertIn("Release signing requires", gradle)

    def test_gradle_distribution_checksum_is_pinned(self):
        props = (ROOT / "android/gradle/wrapper/gradle-wrapper.properties").read_text()
        self.assertIn(
            "distributionSha256Sum=c16d517b50dd28b3f5838f0e844b7520b8f1eb610f2f29de7e4e04a1b7c9c79b",
            props,
        )
        for launcher in (ROOT / "android/gradlew", ROOT / "android/gradlew.bat"):
            self.assertIn(OFFICIAL_WRAPPER_JAR_SHA256, launcher.read_text())

    def test_modified_wrapper_jar_is_rejected_before_gradle_runs(self):
        with tempfile.TemporaryDirectory() as temp:
            android = Path(temp) / "android"
            wrapper = android / "gradle/wrapper"
            wrapper.mkdir(parents=True)
            shutil.copy(ROOT / "android/gradlew", android / "gradlew")
            (wrapper / "gradle-wrapper.jar").write_bytes(b"modified wrapper archive")
            result = subprocess.run(
                ["bash", str(android / "gradlew"), "--version"],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("unverified Gradle wrapper JAR", result.stdout + result.stderr)
            self.assertNotIn("Downloading", result.stdout + result.stderr)

    def test_checked_in_legacy_wrapper_is_blocked_until_upgraded(self):
        jar = ROOT / "android/gradle/wrapper/gradle-wrapper.jar"
        digest = hashlib.sha256(jar.read_bytes()).hexdigest()
        if digest == OFFICIAL_WRAPPER_JAR_SHA256:
            self.skipTest("official Gradle wrapper JAR has replaced the legacy wrapper")
        result = subprocess.run(
            ["bash", str(ROOT / "android/gradlew"), "--version"],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unverified Gradle wrapper JAR", result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
