import importlib.machinery
import importlib.util
import json
import pathlib
import unittest
from unittest import mock


SCRIPT = pathlib.Path(__file__).parents[1] / "bin" / "randomize-fee-configs"
SPEC = importlib.util.spec_from_loader(
    "randomize_fee_configs", importlib.machinery.SourceFileLoader("randomize_fee_configs", str(SCRIPT))
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class Response:
    def __init__(self, payload):
        self.payload = payload

    def read(self):
        return json.dumps(self.payload).encode("utf-8")

    def __enter__(self):
        return self

    def __exit__(self, *args):
        return False


class RandomizeFeeConfigsTest(unittest.TestCase):
    def test_apply_patches_only_rules_for_active_configs(self):
        requests = []

        def urlopen(request, timeout):
            requests.append(request)
            if request.get_method() == "GET":
                return Response({"feeConfigs": [
                    {"id": "one", "status": "active", "basedOn": "mileage", "categoryId": None, "subcategoryId": None, "isDefault": True},
                    {"id": "two", "status": "archived", "basedOn": "bid"},
                ]})
            return Response({"feeConfig": {}})

        with mock.patch.dict(MODULE.os.environ, {"DAEDALUS_ADMIN_TOKEN": "secret"}, clear=True):
            with mock.patch.object(MODULE.urllib.request, "urlopen", side_effect=urlopen):
                MODULE.main(["--apply", "--seed", "1", "--thresholds", "0,100", "--min-fee", "10", "--max-fee", "20"])

        self.assertEqual([request.get_method() for request in requests], ["GET", "PATCH"])
        payload = json.loads(requests[1].data)
        self.assertEqual(set(payload), {"rules"})
        self.assertEqual([rule[0] for rule in payload["rules"]], [0, 100])
        self.assertLessEqual(payload["rules"][0][1], payload["rules"][1][1])
        self.assertEqual(requests[1].get_header("Authorization"), "Bearer secret")


if __name__ == "__main__":
    unittest.main()
