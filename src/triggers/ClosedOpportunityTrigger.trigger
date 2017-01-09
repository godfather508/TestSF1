trigger ClosedOpportunityTrigger on Opportunity (after insert, after update) {
	List<Task> tasks = new List<Task>();
    for (Opportunity o : [SELECT Id FROM Opportunity WHERE Id IN :Trigger.New AND StageName = 'Closed Won' ]) {
        tasks.add(new Task(WhatId=o.id, Subject = 'Follow Up Test Task'));
    }
    if (tasks.size() > 0) {
        insert tasks;
    }
}