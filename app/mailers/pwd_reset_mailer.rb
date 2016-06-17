class PwdResetMailer < ActionMailer::Base
  def reset_token(mail_to_id, reset_token)
    @mail_to_id = mail_to_id
    @reset_token = reset_token
    mail(:to => mail_to_id, :subject => "Your wingle password reset token", :from => "winglecorporation@gmail.com")
    return true
  end
end
