global class nleGoogleSyncScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        nleGoogleSyncBatch b = new nleGoogleSyncBatch();
        database.executebatch(b, 20);
    }
}