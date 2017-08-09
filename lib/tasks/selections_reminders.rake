desc "Send Selections Reminder Email"
task selections_reminder: :environment do
  UserNotifier.selections_reminder_email.deliver!
end
