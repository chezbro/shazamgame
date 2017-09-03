class UserMailer < ActionMailer::Base
  default :from => 'ericchesbrough@gmail.com'

  def selections_reminder_email
    email_list = User.reminder_email_list
    mail(to: email_list, subject: 'SHAZAM13 — Selections Reminder!', body: 'Please remember to make your Selections by Saturday morning at 11AM CST!')
  end

end