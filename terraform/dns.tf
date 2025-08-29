locals {
  route53_zone_id_sanitized = replace(var.route53_zone_id, "/hostedzone/", "")
  interviewee_initials      = lower("${substr(var.interviewee_fn, 0, 1)}${substr(var.interviewee_ln, 0, 1)}")
}

resource "aws_route53_record" "ssh" {
  count   = var.route53_zone_id != "" ? 1 : 0
  zone_id = local.route53_zone_id_sanitized
  name    = "${local.interviewee_initials}-ssh.${var.domain}"
  type    = "A"
  alias {
    name                   = aws_lb.splunk_nlb.dns_name
    zone_id                = aws_lb.splunk_nlb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "searchhead" {
  count   = var.route53_zone_id != "" ? 1 : 0
  zone_id = local.route53_zone_id_sanitized
  name    = "${local.interviewee_initials}-sh.${var.domain}"
  type    = "A"
  alias {
    name                   = aws_lb.splunk_nlb.dns_name
    zone_id                = aws_lb.splunk_nlb.zone_id
    evaluate_target_health = true
  }
}
