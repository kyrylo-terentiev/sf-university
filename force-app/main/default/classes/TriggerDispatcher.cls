public class TriggerDispatcher {
    public static void run(ITriggerHandler handler, String triggerName) {
        if (handler.isDisabled()) {
            return;
        }

        Boolean isActive = TriggerSetting__mdt.getInstance(triggerName)?.isActive__c;
        if (isActive == null) {
            isActive = false;
        }
        if (isActive) {
            System.debug(triggerName + '::' + Trigger.operationType);
            switch on Trigger.operationType {
                when BEFORE_INSERT {
                    handler.beforeInsert(Trigger.new);
                }
                when AFTER_INSERT {
                    handler.afterInsert(Trigger.new, Trigger.newMap);
                }
                when BEFORE_UPDATE {
                    handler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
                when AFTER_UPDATE {
                    handler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
                }
                when BEFORE_DELETE {
                    handler.beforeDelete(Trigger.old, Trigger.oldMap);
                }
                when AFTER_DELETE {
                    handler.afterDelete(Trigger.old, Trigger.oldMap);
                }
                when AFTER_UNDELETE {
                    handler.afterUndelete(Trigger.new, Trigger.newMap);
                }
            }
        }
    }
}
