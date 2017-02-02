# This initializer attaches the log subscribers at `app/subscribers` to the notification hub:
ActiveRecordLogSubscriber.attach_to :active_record
ActionControllerLogSubscriber.attach_to :action_controller
