Rails.configuration.mailchimp = Gibbon::API.new(Rails.application.secrets.mailchimp_key)
MAILCHIMP_LIST_ID = Rails.application.secrets.mailchimp_mailing_list
