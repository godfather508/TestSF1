trigger nleEventTrigger on Event (after insert, after update) {
    if (Trigger.IsAfter) {
        if (Trigger.IsInsert) {
            nleEventTriggerHandler.afterInsert(Trigger.New);
        }
        if (Trigger.IsUpdate) {
            nleEventTriggerHandler.afterUpdate(Trigger.OldMap, Trigger.New);
        }
    }
}