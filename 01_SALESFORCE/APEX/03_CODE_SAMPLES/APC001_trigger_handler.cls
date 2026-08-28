/**
 * #APC001: Enterprise Bulkified Trigger Handler Framework
 *
 * PINCODE:  #APC001
 * Domain:   Apex / Trigger Architecture
 * Status:   Active
 * Last Verified: 2026-08-28
 * Related:  #APL001, #APL002
 *
 * PATTERN
 * -------
 * One trigger per object, delegating immediately to a handler class.
 * The handler is bulk-safe by construction: every context method receives
 * the full Trigger.new / Trigger.old lists, never a single record, so
 * downstream code is forced to work in collections and avoid SOQL/DML
 * inside loops (the #1 governor-limit killer in Apex).
 *
 * A static recursion guard prevents the same handler from re-entering
 * itself when a DML operation inside the handler re-fires the trigger
 * (e.g. an update in afterInsert that touches the same object).
 *
 * USAGE
 * -----
 * trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
 *     new AccountTriggerHandler().run();
 * }
 */
public virtual class TriggerHandler {

    // Recursion guard — one entry per concrete handler type, so unrelated
    // handlers never block each other.
    private static Map<String, Boolean> recursionMap = new Map<String, Boolean>();

    public void run() {
        String handlerName = String.valueOf(this).split(':')[0];

        if (recursionMap.containsKey(handlerName) && recursionMap.get(handlerName)) {
            // Already running for this type in this transaction — skip re-entry.
            return;
        }

        recursionMap.put(handlerName, true);

        switch on Trigger.operationType {
            when BEFORE_INSERT {
                beforeInsert(Trigger.new);
            }
            when BEFORE_UPDATE {
                beforeUpdate(Trigger.new, Trigger.oldMap);
            }
            when BEFORE_DELETE {
                beforeDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_INSERT {
                afterInsert(Trigger.new, Trigger.newMap);
            }
            when AFTER_UPDATE {
                afterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
            }
            when AFTER_DELETE {
                afterDelete(Trigger.old, Trigger.oldMap);
            }
            when AFTER_UNDELETE {
                afterUndelete(Trigger.new, Trigger.newMap);
            }
        }

        recursionMap.put(handlerName, false);
    }

    // Override only the contexts a concrete handler needs — default no-ops
    // keep subclasses free of boilerplate.
    protected virtual void beforeInsert(List<SObject> newRecords) {}
    protected virtual void beforeUpdate(List<SObject> newRecords, Map<Id, SObject> oldMap) {}
    protected virtual void beforeDelete(List<SObject> oldRecords, Map<Id, SObject> oldMap) {}
    protected virtual void afterInsert(List<SObject> newRecords, Map<Id, SObject> newMap) {}
    protected virtual void afterUpdate(List<SObject> newRecords, Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {}
    protected virtual void afterDelete(List<SObject> oldRecords, Map<Id, SObject> oldMap) {}
    protected virtual void afterUndelete(List<SObject> newRecords, Map<Id, SObject> newMap) {}
}

/**
 * Example concrete handler — shows the bulk-safe hash-map bucketing pattern
 * from #APL001 applied inside afterUpdate.
 */
public class AccountTriggerHandler extends TriggerHandler {

    protected override void afterUpdate(List<SObject> newRecords, Map<Id, SObject> newMap, Map<Id, SObject> oldMap) {
        Set<Id> accountIdsThatChangedTier = new Set<Id>();

        for (Account acc : (List<Account>) newRecords) {
            Account oldAcc = (Account) oldMap.get(acc.Id);
            if (acc.Tier__c != oldAcc.Tier__c) {
                accountIdsThatChangedTier.add(acc.Id);
            }
        }

        if (!accountIdsThatChangedTier.isEmpty()) {
            AccountTierService.recalculateOverdueAlerts(accountIdsThatChangedTier);
        }
    }
}
