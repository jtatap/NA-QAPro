/**
 * Class TriggerFactory
 *
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 */
public without sharing class TriggerFactory
{
      
    /**
    * private static method to get the appropriate handler for the class type
    * No modifications requried in this method
    *
    * Arguments: Type - Class Type, which implements ITrigger interface
    *
    * Returns: ITrigger - A trigger handler if one exists or null
    */
    @testVisible
    private static ITrigger getHandler(Type classType){
        System.debug('***inside getHandler');
        // Instantiate the type
        
        Object o = classType.newInstance();
 
        // if its not an instance of ITrigger return null
        if (!(o instanceOf ITrigger)) {
            return null;
        }
 
        return (ITrigger)o;
    }
    
    
    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Type classType - The class to instantiate and execute
     *
     * Throws a TriggerException if no handler is found.
     */
    public static void createAndExecuteHandler(Type classType)
    {
        System.debug('***inside createAndExecuteHandler');
        // Get a handler appropriate to the class being processed
        ITrigger handler = getHandler(classType);
        System.debug('Handler = '+handler);
        // Make sure we have a handler implements ITrigger
        if (handler == null)
        {
            throw new TriggerException('No Trigger Handler registered for Class Type: ' + classType.getName());
        }
        
        // Execute the handler to fulfil the trigger		
		if (utilityClass.triggerEnabled(classType)) {
			execute(handler); 
		} else {
			 System.debug('Skip trigger execution because override found in TriggerFactoryOverride__mdt');
		}
    }
    
    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */ 
    private static void execute(ITrigger handler)
    {
        System.debug('***inside Execute');
        // Before Trigger
        if (Trigger.isBefore)
        {
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();
            
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete)
            {
                for (SObject so : Trigger.old)
                {
                    handler.beforeDelete(so);
                }
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
                for (SObject so : Trigger.new)
                {
                    handler.beforeInsert(so);
                }
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
                for (SObject so : Trigger.old)
                {
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            
            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete)
            {
                for (SObject so : Trigger.old)
                {
                    handler.afterDelete(so);
                }
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
                System.debug('***inside after insert');
                for (SObject so : Trigger.new)
                {
                    handler.afterInsert(so);
                }
                System.debug('***finished after insert');
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
                for (SObject so : Trigger.old)
                {
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        
        // Perform any post processing
        System.debug('***running finally');
        handler.andFinally();
    }
    

}