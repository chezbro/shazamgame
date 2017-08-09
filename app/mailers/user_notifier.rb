class UserNotifier < ActionMailer::Base
  default :from => 'ericchesbrough@gmail.com'

  def selections_reminder_email
    emails = User.all.collect(&:email).join(", ")
    mail(to: emails, subject: 'SHAZAM13 — Selections Reminder!', body: 'Please remember to make your Selections by tomorrow morning at 11AM CST!')
  end

end
