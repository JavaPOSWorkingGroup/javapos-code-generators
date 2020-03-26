package jpos.build.controls

import java.io.File
import java.lang.reflect.Parameter
import jpos.BeltControl114
import jpos.BillAcceptorControl114
import jpos.BillDispenserControl114
import jpos.BiometricsControl114
import jpos.BumpBarControl114
import jpos.CATControl114
import jpos.CashChangerControl114
import jpos.CashDrawerControl114
import jpos.CheckScannerControl114
import jpos.CoinAcceptorControl114
import jpos.CoinDispenserControl114
import jpos.ElectronicJournalControl114
import jpos.ElectronicValueRWControl114
import jpos.FiscalPrinterControl114
import jpos.GateControl114
import jpos.HardTotalsControl114
import jpos.ImageScannerControl114
import jpos.ItemDispenserControl114
import jpos.KeylockControl114
import jpos.LightsControl114
import jpos.LineDisplayControl114
import jpos.MICRControl114
import jpos.MSRControl114
import jpos.MotionSensorControl114
import jpos.PINPadControl114
import jpos.POSKeyboardControl114
import jpos.POSPowerControl114
import jpos.POSPrinterControl114
import jpos.PointCardRWControl114
import jpos.RFIDScannerControl114
import jpos.RemoteOrderDisplayControl114
import jpos.ScaleControl114
import jpos.ScannerControl114
import jpos.SignatureCaptureControl114
import jpos.SmartCardRWControl114
import jpos.ToneIndicatorControl114
import jpos.build.SynthesizeHelper
import jpos.build.UPOSModelReader
import jpos.build.UPOSModelReaderConfiguration
import jpos.build.UposCategory
import jpos.build.UposEvent
import jpos.build.UposMethod
import jpos.build.UposModel
import jpos.build.UposProperty
import org.junit.Test

import static extension jpos.build.SynthesizeHelper.argumentList
import static extension jpos.build.SynthesizeHelper.hasArrayParameterTypes
import static extension jpos.build.SynthesizeHelper.isUposArrayType
import static extension jpos.build.SynthesizeHelper.javaPOSType
import static extension jpos.build.SynthesizeHelper.parameterList
import static extension jpos.build.SynthesizeHelper.restrictedMiniumMinorVersionNumber
import static extension jpos.build.SynthesizeHelper.versionWhenAddedToUPOS

class JavaPOSDeviceControlGenerator {
    
    // adapt this if a new UnifiedPOS minor version is going to be supported
    static val currentUnfiedPOSMinorVersion = 14

    // adapt this for controlling the version range of the to be generated device controls
    static val supportedUnifiedPOSMinorVersionRange = (2..currentUnfiedPOSMinorVersion) 
    
    // adapt this if your javapos-controls project has another name
    static val generatedSourceDir = new File("../javapos-controls/src/main/java/jpos")
    
    
    extension UPOSModelReader modelReader = new UPOSModelReader => [
        configuration = new UPOSModelReaderConfiguration => [
            supportedCategories = #
            [
                CashDrawerControl114
//                BumpBarControl114, 
//                CashChangerControl114,
//                CashDrawerControl114,
//                CATControl114,
//                CheckScannerControl114, 
//                CoinDispenserControl114, 
//                FiscalPrinterControl114, 
//                HardTotalsControl114,
//                KeylockControl114,
//                LineDisplayControl114, 
//                MICRControl114,
//                MotionSensorControl114,
//                MSRControl114,
//                PINPadControl114, 
//                PointCardRWControl114, 
//                POSKeyboardControl114,
//                POSPowerControl114,
//                POSPrinterControl114, 
//                RemoteOrderDisplayControl114, 
//                ScaleControl114,
//                ScannerControl114, 
//                SignatureCaptureControl114, 
//                ToneIndicatorControl114,
//                BeltControl114,
//                BillAcceptorControl114, 
//                BillDispenserControl114, 
//                CoinAcceptorControl114,
//                CoinDispenserControl114,
//                BiometricsControl114,
//                ElectronicJournalControl114, 
//                ElectronicValueRWControl114,
//                GateControl114,
//                ImageScannerControl114,  
//                ItemDispenserControl114, 
//                LightsControl114,
//                RFIDScannerControl114, 
//                SmartCardRWControl114
            ]
            omittedReadProperties = #
            { 
                // the following getters are already specified in BaseJposControl
                'getCheckHealthText', 
                'getClaimed',
                'getDeviceControlDescription',
                'getDeviceControlVersion',
                'getDeviceEnabled',
                'getDeviceServiceDescription',
                'getDeviceServiceVersion',
                'getFreezeEvents',
                'getPhysicalDeviceDescription',
                'getPhysicalDeviceName',
                'getState'
            }
            omittedWriteProperties = #
            {
                // the following setters are already specified in BaseJposControl
                'setDeviceEnabled',
                'setFreezeEvents'
            }
            omittedMethods = #
            { 
                // the following methods are already specified in BaseService
                'claim',
                'close',
                'checkHealth',
                'directIO',
                'open',
                'release'
            }
            
        ]
    ]

    static val allEvents = #["Data", "DirectIO", "Error", "StatusUpdate", "OutputComplete", "Transition"]
    
    /**
     * Main class for code generation.<br>
     * Currently realized as Unit test for getting a fast and convenient interactive 
     * access to the generation functionality trough the JUnit Eclipse view.  
     */
    @Test
    def void generate() {
        val uposModel = readUposModelFor('JavaPOSDeviceControls')
        uposModel.synthesize
    }
    
    /**
     * Synthesize all files for the passed UnifiedPOS model 
     */
    def private static synthesize(UposModel model) {
       generatedSourceDir.mkdirs() 
        model.categories?.forEach[synthesizeDeviceControlSourceFile]
    }
    
    
    /**
     * Synthesizes a java source code file for the given category and writes it to the given directory.
     * @param category the UnifiedPOS category as returned by {@link UposModelreader} code has to be synthesized for
     * @param outputDir the directory the java file has to be written to 
     */
    def private static synthesizeDeviceControlSourceFile(UposCategory category) {
        SynthesizeHelper.generateFile(
            new File(generatedSourceDir, '''«category.name».java'''), 
            category.deviceControlClass
        )
    }
    
    /**
     * Synthesizes the code for a particular UnifedPOS method or property passed.
     */
    def private static String deviceControlClass(UposCategory category) '''
        //////////////////////////////////////////////////////////////////////
        //
        // The JavaPOS library source code is now under the CPL license, which 
        // is an OSS Apache-like license. The complete license is located at:
        //    http://www.ibm.com/developerworks/library/os-cpl.html
        //
        //////////////////////////////////////////////////////////////////////
        //------------------------------------------------------------------------------
        //
        // This software is provided "AS IS".  The JavaPOS working group (including
        // each of the Corporate members, contributors and individuals)  MAKES NO
        // REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
        // EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
        // WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
        // NON-INFRINGEMENT. The JavaPOS working group shall not be liable for
        // any damages suffered as a result of using, modifying or distributing this
        // software or its derivatives.Permission to use, copy, modify, and distribute
        // the software and its documentation for any purpose is hereby granted.
        //
        // «category.name».java - A JavaPOS 1.«currentUnfiedPOSMinorVersion».0 device control
        //
        //------------------------------------------------------------------------------
        
        package jpos;
        
        import jpos.events.*;
        import jpos.services.*;
        import java.util.Vector;
        import jpos.loader.*;
        
        public class «category.name»
            extends BaseJposControl
            implements «category.name»Control1«currentUnfiedPOSMinorVersion», JposConst
        {
            //--------------------------------------------------------------------------
            // Variables
            //--------------------------------------------------------------------------
        
            «supportedUnifiedPOSMinorVersionRange.map[minorVersion | 
                '''protected «category.name»Service1«category.restrictedMiniumMinorVersionNumber(minorVersion)» service1«minorVersion»;'''
            ].join('\n')»
            «category.events?.map[deviceControlEventListenersDeclaration]?.join»
            
        
            //--------------------------------------------------------------------------
            // Constructor
            //--------------------------------------------------------------------------
        
            public «category.name»()
            {
                // Initialize base class instance data
                deviceControlDescription = "JavaPOS «category.name» Device Control";
                deviceControlVersion = deviceVersion1«currentUnfiedPOSMinorVersion»;
                
                // Initialize instance data. Initializations are commented out for
                // efficiency if the Java default is correct.
                «supportedUnifiedPOSMinorVersionRange.map[minorVersion | '''//service1«minorVersion» = null;'''].join('\n')»
                «category.events?.map[deviceControlEventListenersInitialization]?.join»
            }
            
            //--------------------------------------------------------------------------
            // Capabilities
            //--------------------------------------------------------------------------
            
            «category.properties?.filter[name.startsWith("Cap")].map[deviceControlProperty]?.join('\n')»
            
            //--------------------------------------------------------------------------
            // Properties
            //--------------------------------------------------------------------------
            
            «category.properties?.filter[!name.startsWith("Cap")].map[deviceControlProperty]?.join('\n')»
            
            //--------------------------------------------------------------------------
            // Methods
            //--------------------------------------------------------------------------
            
            «category.methods?.map[deviceControlMethod]?.join('\n')»
            
            //--------------------------------------------------------------------------
            // Framework Methods
            //--------------------------------------------------------------------------
            
            // Create an EventCallbacks interface implementation object for this Control
            protected EventCallbacks createEventCallbacks()
            {
              return new «category.name»Callbacks();
            }
            
            // Store the reference to the Device Service
            protected void setDeviceService(BaseService service, int nServiceVersion)
            throws JposException
            {
                // Special case: service == null to free references
                if(service == null)
                {
                    «supportedUnifiedPOSMinorVersionRange.map[minorVersion|'''service1«minorVersion» = null;'''].join('\n')»
                }
                else
                {
                    // Make sure that the service actually conforms to the interfaces it
                    // claims to.
                    «supportedUnifiedPOSMinorVersionRange.map[minorVersion|category.serviceAssignment(minorVersion)].join»
                    
                }
            }
            
            //--------------------------------------------------------------------------
            // Event Listener Methods
            //--------------------------------------------------------------------------
            
            «category.events?.map[eventRegistrationMethods].join»
            
            //--------------------------------------------------------------------------
            // EventCallbacks inner class
            //--------------------------------------------------------------------------
            
            protected class «category.name»Callbacks
                implements «category.callbacksToBeImplemented»
            {
                public BaseControl getEventSource()
                {
                    return (BaseControl)«category.name».this;
                }
                
                «allEvents.map[fireEventMethod(category)]?.join('\n')»
            }
        }
    '''
    
    def private static callbacksToBeImplemented(UposCategory category) {
        switch (category.name) {
            case 'ElectronicValueRW': {
                'EventCallbacks2'
            }
            default: {
                'EventCallbacks'
            }
        }
    }
    
    def private static serviceAssignment(UposCategory category, int minorVersionNumber) {
        var appliedMinorVersion = category.restrictedMiniumMinorVersionNumber(minorVersionNumber)
        '''
            if(serviceVersion >= deviceVersion1«minorVersionNumber»)
            {
                try
                {
                    service1«minorVersionNumber» = («category.name»Service1«appliedMinorVersion»)service;
                }
                catch(Exception e)
                {
                    throw new JposException(JPOS_E_NOSERVICE,
                                            "Service does not fully implement «category.name»Service1«minorVersionNumber» interface",
                                            e);
                }
            }
        '''
    }
    
    /**
     * Synthesizes the code for a particular UnifedPOS method.
     */
    def private static deviceControlMethod(UposMethod method) '''
        public void «method.name»(«method.parameterList»)
            throws JposException
        {
            // Make sure control is opened
            if(!bOpen)
            {
                throw new JposException(JPOS_E_CLOSED, "Control not opened");
            }
            
            «IF method.minorVersionAdded > 2»
                // Make sure service supports at least version 1.«method.minorVersionAdded».0
                if(serviceVersion < deviceVersion«method.versionWhenAddedToUPOS»)
                {
                    throw new JposException(JPOS_E_NOSERVICE,
                                            "Device Service is not 1.«method.minorVersionAdded».0 compliant.");
                }
            «ENDIF»
            
            // Perform the operation
            try
            {
                service«method.versionWhenAddedToUPOS».«method.name»(«method.argumentList»);«»
            }
            catch(JposException je)
            {
                throw je;
            }
            catch(Exception e)
            {
                throw new JposException(JPOS_E_FAILURE, 
                                        "Unhandled exception from Device Service", e);
            }
        }    
    '''
    
    def private static deviceControlEventListenersDeclaration(UposEvent event) '''
        protected Vector «event.name.toFirstLower»Listeners;
    '''

    def private static deviceControlEventListenersInitialization(UposEvent event) '''
        «event.name.toFirstLower»Listeners = new Vector();
    '''
    
    def private static String deviceControlProperty(UposProperty property) {
        switch property.name {
            
            // special handling for FiscalPrinter set methods which are not properties
            case 'Currency': property.deviceControlSetPropertyMethod
            case 'Date': property.deviceControlSetPropertyMethod
            case 'StoreFiscalID': property.deviceControlSetPropertyMethod

            // special handling of ElectronicValueRW property which lacks of the "get" prefix in the Java method
            case property.name == 'CapTrainingMode' && property.categoryBelongingTo.name.startsWith('ElectronicValueRW'): 
                property.deviceControlGetPropertyMethodForWronglyNamedElectronicValueRWCapTrainingMode

            // special handling of Sale property which has a spelling error and is defined twice (wrongly spelled and right spelled) 
            case property.name == 'TarePriority': // && property.categoryBelongingTo.name.startsWith('Sale'): 
                property.deviceControlSetPropertyMethodForWronglySpelledScaleTarePriority
            
            default: 
                property.deviceControlPropertyMethodWithJposException        
        }
    }
    
    def private static String deviceControlPropertyMethodWithJposException(UposProperty property) '''
        «property.deviceControlGetPropertyMethod»
        «property.deviceControlSetPropertyMethod»
    '''
    
    def private static String deviceControlSetPropertyMethodForWronglySpelledScaleTarePriority(UposProperty property)
    '''
        public void set«property.name»(«property.javaPOSType» «property.name.toFirstLower»)
            throws JposException
        {
            // Make sure control is opened
            if(!bOpen)
            {
                throw new JposException(JPOS_E_CLOSED, "Control not opened");
            }
            
            // Make sure service supports at least version 1.«property.minorVersionAdded».0
            if(serviceVersion < deviceVersion«property.versionWhenAddedToUPOS»)
            {
                throw new JposException(JPOS_E_NOSERVICE,
                                        "Device Service is not 1.«property.minorVersionAdded».0 compliant.");
            }
            
            // Perform the operation
            try
            {
                service«property.versionWhenAddedToUPOS».setTarePrioity(«property.name.toFirstLower»);
            }
            catch(JposException je)
            {
                throw je;
            }
            catch(Exception e)
            {
                throw new JposException(JPOS_E_FAILURE, 
                                        "Unhandled exception from Device Service", e);
            }
        }
    '''

    
    def private static String deviceControlGetPropertyMethod(UposProperty property) '''
        public «property.javaPOSType» get«property.name»()
            throws JposException
        {
            // Make sure control is opened
            if(!bOpen)
            {
                throw new JposException(JPOS_E_CLOSED, "Control not opened");
            }
            
            «IF property.minorVersionAdded > 2»
                // Make sure service supports at least version 1.«property.minorVersionAdded».0
                if(serviceVersion < deviceVersion«property.versionWhenAddedToUPOS»)
                {
                    throw new JposException(JPOS_E_NOSERVICE,
                                            "Device Service is not 1.«property.minorVersionAdded».0 compliant.");
                }
            «ENDIF»
            
            // Perform the operation
            try
            {
                return service«property.versionWhenAddedToUPOS».get«property.name»();
            }
            catch(JposException je)
            {
                throw je;
            }
            catch(Exception e)
            {
                throw new JposException(JPOS_E_FAILURE,
                                        "Unhandled exception from Device Service", e);
            }
        }
    '''
    
    /**
     * Special handling of ElectronicValueRW property CapTrainingMode added in UnfiedPOS 1.14
     * which lacks of the "get" prefix in the Java method breaking our generator schema.
     */
    def private static String deviceControlGetPropertyMethodForWronglyNamedElectronicValueRWCapTrainingMode(UposProperty property) '''
        public «property.javaPOSType» «property.name»()
            throws JposException
        {
            // Make sure control is opened
            if(!bOpen)
            {
                throw new JposException(JPOS_E_CLOSED, "Control not opened");
            }
            
            // Make sure service supports at least version 1.«property.minorVersionAdded».0
            if(serviceVersion < deviceVersion«property.versionWhenAddedToUPOS»)
            {
                throw new JposException(JPOS_E_NOSERVICE,
                                        "Device Service is not 1.«property.minorVersionAdded».0 compliant.");
            }
            
            // Perform the operation
            try
            {
                return service«property.versionWhenAddedToUPOS».«property.name»();
            }
            catch(JposException je)
            {
                throw je;
            }
            catch(Exception e)
            {
                throw new JposException(JPOS_E_FAILURE,
                                        "Unhandled exception from Device Service", e);
            }
        }

        public «property.javaPOSType» get«property.name»()
            throws JposException
        {
            // Make sure control is opened
            if(!bOpen)
            {
                throw new JposException(JPOS_E_CLOSED, "Control not opened");
            }
            
            // Make sure service supports at least version 1.«property.minorVersionAdded».0
            if(serviceVersion < deviceVersion«property.versionWhenAddedToUPOS»)
            {
                throw new JposException(JPOS_E_NOSERVICE,
                                        "Device Service is not 1.«property.minorVersionAdded».0 compliant.");
            }
            
            // Perform the operation
            try
            {
                return service«property.versionWhenAddedToUPOS».«property.name»();
            }
            catch(JposException je)
            {
                throw je;
            }
            catch(Exception e)
            {
                throw new JposException(JPOS_E_FAILURE,
                                        "Unhandled exception from Device Service", e);
            }
        }
    '''


    def private static String deviceControlSetPropertyMethod(UposProperty property) {
        if (!property.readonly)
            '''
                public void set«property.name»(«property.javaPOSType» «property.name.toFirstLower»)
                    throws JposException
                {
                    // Make sure control is opened
                    if(!bOpen)
                    {
                        throw new JposException(JPOS_E_CLOSED, "Control not opened");
                    }
                    
                    // Make sure service supports at least version 1.«property.minorVersionAdded».0
                    if(serviceVersion < deviceVersion«property.versionWhenAddedToUPOS»)
                    {
                        throw new JposException(JPOS_E_NOSERVICE,
                                                "Device Service is not 1.«property.minorVersionAdded».0 compliant.");
                    }
                    
                    // Perform the operation
                    try
                    {
                        service«property.versionWhenAddedToUPOS».set«property.name»(«property.name.toFirstLower»);
                    }
                    catch(JposException je)
                    {
                        throw je;
                    }
                    catch(Exception e)
                    {
                        throw new JposException(JPOS_E_FAILURE, 
                                                "Unhandled exception from Device Service", e);
                    }
                }
            '''
        else 
            ''
        
    }
    
    def private static eventRegistrationMethods(UposEvent event) '''
        public void add«event.name»Listener(«event.name»Listener l)
        {
            synchronized(«event.name.toFirstLower»Listeners)
            {
                «event.name.toFirstLower»Listeners.addElement(l);
            }
        }
        
        public void remove«event.name»Listener(«event.name»Listener l)
        {
            synchronized(«event.name.toFirstLower»Listeners)
            {
                «event.name.toFirstLower»Listeners.removeElement(l);
            }
        }
    '''

    def private static fireEventMethod(String eventName, UposCategory category) {
        if (category.callbacksToBeImplemented == 'EventCallbacks' && eventName == 'Transition')
            // TransitionEvent stuff must generated only if EventCallbacks2 gets implement
            ''
        else
            '''
                public void fire«eventName»Event(«eventName»Event e)
                {
                    «IF category.events.map[name].contains(eventName)»
                        synchronized(«category.name».this.«eventName.toFirstLower»Listeners)
                        {
                            // deliver the event to all registered listeners
                            for(int x = 0; x < «eventName.toFirstLower»Listeners.size(); x++)
                            {
                              ((«eventName»Listener)«eventName.toFirstLower»Listeners.elementAt(x)).«eventName.toFirstLower»Occurred(e);
                            }
                        }
                    «ENDIF»
                }
            ''' 
    } 
    
}


