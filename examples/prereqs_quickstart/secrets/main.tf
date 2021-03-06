/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

resource "aws_secretsmanager_secret" "federation" {
  name_prefix             = var.resource_name_prefix
  description             = "contains Consul federation secrets"
  recovery_window_in_days = 0
}
