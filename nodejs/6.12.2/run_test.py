import unittest
import subprocess


class TestBinaries(unittest.TestCase):
    def test_node_version(self):
        version = subprocess.check_output(['node', '--version']) \
                            .decode('utf-8')
        self.assertEqual(version.strip(), 'v6.12.2')

    def test_npm_version(self):
        version = subprocess.check_output(['npm', '--version']) \
                            .decode('utf-8')
        self.assertEqual(version.strip(), '4.5.0')

    def test_npm_version(self):
        version = subprocess.check_output(['yarn', '--version']) \
                            .decode('utf-8')
        self.assertEqual(version.strip(), '1.3.2')

    def test_grunt_version(self):
        versionsb = subprocess.check_output(['grunt', '--version']) \
                              .decode('utf-8')
        versionss = versionsb.splitlines()
        print(versionss)
        self.assertEqual(len(versionss), 1)
        if len(versionss) == 1:
            self.assertEqual(versionss[0].strip(), 'grunt-cli v1.2.0')

    def test_npm_version(self):
        version = subprocess.check_output(['bower', '--version']) \
                            .decode('utf-8')
        self.assertEqual(version.strip(), '1.8.2')


if __name__ == "__main__":
    unittest.main()
