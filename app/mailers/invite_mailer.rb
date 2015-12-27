class InviteMailer < ActionMailer::Base
  # default from: "tanweer.shahzaad@gmail.com"

  def invit_email(mail_to_id)
    # delivery_options = { user_name: "Tanweer Shahzaad",
    #                      password: "Developer",
    #                      address: "tanweer.shahzaad@gmail.com" }

    # mail(to: "bsef11m033@pucit.edu.pk",
    #      subject: "Please see the Terms and Conditions attached")
    # mail(to: "bsef11m033@pucit.edu.pk",
    #      subject: "Please see the Terms and Conditions attached",
    #      delivery_method_options: delivery_options)
    @mail_to_id = mail_to_id
    mail(:to => mail_to_id, :subject => "Invitation to Wingle(Where people meet)", :from => "email.wingle@gmail.com")
    #
    # mail(:to => email, :subject => "invitation", :from => "ionlaquete@gmail.com")
    return true
  end
end
