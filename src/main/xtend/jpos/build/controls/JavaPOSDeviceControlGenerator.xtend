package jpos.build.controls

import java.io.File
import jpos.BeltControl116
import jpos.BillAcceptorControl116
import jpos.BillDispenserControl116
import jpos.BiometricsControl116
import jpos.BumpBarControl116
import jpos.CATControl116
import jpos.CashChangerControl116
import jpos.CashDrawerControl116
import jpos.CheckScannerControl116
import jpos.CoinAcceptorControl116
import jpos.CoinDispenserControl116
import jpos.ElectronicJournalControl116
import jpos.ElectronicValueRWControl116
import jpos.FiscalPrinterControl116
import jpos.GateControl116
import jpos.HardTotalsControl116
import jpos.ImageScannerControl116
import jpos.ItemDispenserControl116
import jpos.KeylockControl116
import jpos.LightsControl116
import jpos.LineDisplayControl116
import jpos.MICRControl116
import jpos.MSRControl116
import jpos.MotionSensorControl116
import jpos.PINPadControl116
import jpos.POSKeyboardControl116
import jpos.POSPowerControl116
import jpos.POSPrinterControl116
import jpos.PointCardRWControl116
import jpos.RFIDScannerControl116
import jpos.RemoteOrderDisplayControl116
import jpos.ScaleControl116
import jpos.ScannerControl116
import jpos.SignatureCaptureControl116
import jpos.SmartCardRWControl116
import jpos.ToneIndicatorControl116
import jpos.DeviceMonitorControl116
import jpos.GestureControlControl116
import jpos.GraphicDisplayControl116
import jpos.IndividualRecognitionControl116
import jpos.SoundPlayerControl116
import jpos.SoundRecorderControl116
import jpos.SpeechSynthesisControl116
import jpos.VideoCaptureControl116
import jpos.VoiceRecognitionControl116
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
import static extension jpos.build.SynthesizeHelper.javaPOSType
import static extension jpos.build.SynthesizeHelper.parameterList
import static extension jpos.build.SynthesizeHelper.restrictedMiniumMinorVersionNumber
import static extension jpos.build.SynthesizeHelper.versionWhenAddedToUPOS

class JavaPOSDeviceControlGenerator {
    
    // adapt this if a new UnifiedPOS minor version is going to be supported
    static val currentUnfiedPOSMinorVersion = 16

    // adapt this if your javapos-controls project has another name
    static val generatedSourceDir = new File("../javapos-controls/src/main/java/jpos")
    
    
    extension UPOSModelReader modelReader = new UPOSModelReader => [
        configuration = new UPOSModelReaderConfiguration => [
            supportedCategories = #
            [
                BumpBarControl116, 
                CashChangerControl116,
                CashDrawerControl116,
                CATControl116,
                CheckScannerControl116, 
                CoinDispenserControl116, 
                FiscalPrinterControl116, 
                HardTotalsControl116,
                KeylockControl116,
                LineDisplayControl116, 
                MICRControl116,
                MotionSensorControl116,
                MSRControl116,
                PINPadControl116, 
                PointCardRWControl116, 
                POSKeyboardControl116,
                POSPowerControl116,
                POSPrinterControl116, 
                RemoteOrderDisplayControl116, 
                ScaleControl116,
                ScannerControl116, 
                SignatureCaptureControl116, 
                ToneIndicatorControl116,
                BeltControl116,
                BillAcceptorControl116, 
                BillDispenserControl116, 
                CoinAcceptorControl116,
                CoinDispenserControl116,
                BiometricsControl116,
                ElectronicJournalControl116, 
                ElectronicValueRWControl116,
                GateControl116,
                ImageScannerControl116,  
                ItemDispenserControl116, 
                LightsControl116,
                RFIDScannerControl116, 
                SmartCardRWControl116,
                // new in UPOS 1.16
                DeviceMonitorControl116,
                GestureControlControl116,
                GraphicDisplayControl116,
                IndividualRecognitionControl116,
                SoundPlayerControl116,
                SoundRecorderControl116,
                SpeechSynthesisControl116,
                VideoCaptureControl116,
                VoiceRecognitionControl116                
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
    static val supportedUnifiedPOSMinorVersionRange = (2..currentUnfiedPOSMinorVersion) 
    
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
        
        import java.util.ArrayList;
        import java.util.List;
        
        public class «category.name»
            extends BaseJposControl
            implements «category.name»Control1«currentUnfiedPOSMinorVersion», JposConst
        {
            //--------------------------------------------------------------------------
            // Variables
            //--------------------------------------------------------------------------
        
            «supportedUnifiedPOSMinorVersionRange
                .filter[it >= category.minorVersionAdded]
                .map[minorVersion |'''protected «category.name»Service1«minorVersion» service1«minorVersion»;''']
                .join('\n')»
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
                «supportedUnifiedPOSMinorVersionRange
                    .filter[it >= category.minorVersionAdded]
                    .map[minorVersion | '''//service1«minorVersion» = null;''']
                    .join('\n')»
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
                    «supportedUnifiedPOSMinorVersionRange
                        .filter[it >= category.minorVersionAdded]
                        .map[minorVersion|'''service1«minorVersion» = null;''']
                        .join('\n')»
                }
                else
                {
                    // Make sure that the service actually conforms to the interfaces it
                    // claims to.
                    «supportedUnifiedPOSMinorVersionRange
                        .filter[it >= category.minorVersionAdded]
                        .map[minorVersion|category.serviceAssignment(minorVersion)]
                        .join»
                    
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
    def private static deviceControlMethod(UposMethod method) {
        switch (method.name) {
            // special handling of Sale property which has a spelling error and is defined twice (wrongly spelled and right spelled) 
            case 'setTarePriority': // && property.categoryBelongingTo.name.startsWith('Sale'): 
                method.deviceControlSetPropertyMethodForWronglySpelledScaleTarePriority
            case 'setTarePrioity': // && property.categoryBelongingTo.name.startsWith('Sale'): 
                '''
                    public void setTarePrioity(int priority)
                            throws JposException
                    {
                        setTarePriority(priority);
                    }
                '''
        	default: 
                '''
                    public void «method.name»(«method.parameterList»)
                        throws JposException
                    {
                        // Make sure control is opened
                        if(!bOpen)
                        {
                            throw new JposException(JPOS_E_CLOSED, "Control not opened");
                        }
                        
                        «IF method.minorVersionAdded > method.categoryBelongingTo.minorVersionAdded»
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
        }
    }
    
    def private static deviceControlEventListenersDeclaration(UposEvent event) '''
        protected List<«event.name»Listener> «event.name.toFirstLower»Listeners;
    '''

    def private static deviceControlEventListenersInitialization(UposEvent event) '''
        «event.name.toFirstLower»Listeners = new ArrayList<«event.name»Listener>();
    '''
    
    def private static String deviceControlProperty(UposProperty property) {
        switch property.name {
            
            // special handling for FiscalPrinter set methods which are not properties
            case 'Currency': property.deviceControlSetPropertyMethod
            case 'Date': property.deviceControlSetPropertyMethod
            case 'StoreFiscalID': property.deviceControlSetPropertyMethod

            // special handling of ElectronicValueRW property which lacks of the "get" prefix in the Java method
            case property.javaMethod.name == 'CapTrainingMode' && property.categoryBelongingTo.name == 'ElectronicValueRW':
                property.deviceControlGetPropertyMethodForWronglyNamedElectronicValueRWCapTrainingMode
            case property.javaMethod.name == 'getCapTrainingMode' && property.categoryBelongingTo.name == 'ElectronicValueRW': 
                '' // because property CapTrainingMode is contained twice in the read model of ElectronicValueRW

            default: 
                property.deviceControlPropertyMethodWithJposException        
        }
    }
    
    def private static String deviceControlPropertyMethodWithJposException(UposProperty property) '''
        «property.deviceControlGetPropertyMethod»
        «property.deviceControlSetPropertyMethod»
    '''
    
    def private static String deviceControlSetPropertyMethodForWronglySpelledScaleTarePriority(UposMethod method) {
        val setterVariableName = method.javaMethod.parameters.head.name
        '''
            public void «method.name»(«method.javaMethod.parameters.head.type» «setterVariableName»)
                throws JposException
            {
                // Make sure control is opened
                if(!bOpen)
                {
                    throw new JposException(JPOS_E_CLOSED, "Control not opened");
                }
                
                // Make sure service supports at least version 1.«method.minorVersionAdded».0
                if(serviceVersion < deviceVersion«method.versionWhenAddedToUPOS»)
                {
                    throw new JposException(JPOS_E_NOSERVICE,
                                            "Device Service is not 1.«method.minorVersionAdded».0 compliant.");
                }
                
                // Perform the operation
                try
                {
                    service«method.versionWhenAddedToUPOS».setTarePrioity(«setterVariableName»);
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
    }

    
    def private static String deviceControlGetPropertyMethod(UposProperty property) '''
        public «property.javaPOSType» get«property.name»()
            throws JposException
        {
            // Make sure control is opened
            if(!bOpen)
            {
                throw new JposException(JPOS_E_CLOSED, "Control not opened");
            }
            
            «IF property.minorVersionAdded > property.categoryBelongingTo.minorVersionAdded»
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
        	return get«property.name»();
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
        if (!property.readonly) {
        	val setterVariableName = property.javaMethod.parameters.head.name
            '''
                public void set«property.name»(«property.javaPOSType» «setterVariableName»)
                    throws JposException
                {
                    // Make sure control is opened
                    if(!bOpen)
                    {
                        throw new JposException(JPOS_E_CLOSED, "Control not opened");
                    }
                    
                    
                    «IF property.minorVersionAdded > property.categoryBelongingTo.minorVersionAdded»
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
                        service«property.versionWhenAddedToUPOS».set«property.name»(«setterVariableName»);
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
        }
        else 
            ''
        
    }
    
    def private static eventRegistrationMethods(UposEvent event) '''
        public void add«event.name»Listener(«event.name»Listener l)
        {
            synchronized(«event.name.toFirstLower»Listeners)
            {
                «event.name.toFirstLower»Listeners.add(l);
            }
        }
        
        public void remove«event.name»Listener(«event.name»Listener l)
        {
            synchronized(«event.name.toFirstLower»Listeners)
            {
                «event.name.toFirstLower»Listeners.remove(l);
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
                            for («eventName»Listener «eventName.toFirstLower»Listener : «category.name».this.«eventName.toFirstLower»Listeners) {
                            	«eventName.toFirstLower»Listener.«eventName.toFirstLower»Occurred(e);
                            }
                        }
                    «ENDIF»
                }
            ''' 
    } 
    
}


