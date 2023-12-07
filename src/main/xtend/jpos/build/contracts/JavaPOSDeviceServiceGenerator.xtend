package jpos.build.contracts

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
import jpos.build.UposMethod
import jpos.build.UposModel
import jpos.build.UposProperty
import org.junit.Test

import static extension jpos.build.SynthesizeHelper.humanReadableName
import static extension jpos.build.SynthesizeHelper.javaPOSType
import static extension jpos.build.SynthesizeHelper.parameterList

class JavaPOSDeviceServiceGenerator {
    
    // adapt this if a new UnifiedPOS minor version is going to be supported
    static val currentUnfiedPOSMinorVersion = 16
    
    // adapt this for controlling the version range of the to be generated service interface files 
	static val supportedUnifiedPOSMinorVersionRange = (2..currentUnfiedPOSMinorVersion)
	
	// adapt this if your javapos-contracts project has another name
    static val generatedSourceDir = new File("../javapos-contracts/src/main/java/jpos/services")
    	
    
    extension UPOSModelReader modelReader = new UPOSModelReader => [
        configuration = new UPOSModelReaderConfiguration => [
            supportedCategories = #
            [
                BumpBarControl116, 
                CashChangerControl116,
                CashDrawerControl116,
                CATControl116,
                CheckScannerControl116, 
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
            	// the following getters are already specified in BaseService
            	'getCheckHealthText', 
            	'getClaimed',
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
            	// the following setters are already specified in BaseService
                'setDeviceEnabled',
            	'getFreezeEvents'
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
        model.categories?.forEach[synthesizeDeviceControlSourceFile(generatedSourceDir)]
    }

    /**
     * Synthesizes a java source code file for the given category and writes it to the given directory.
     * @param category the UnifiedPOS category as returned by {@link UposModelreader} code has to be synthesized for
     * @param outputDir the directory the java file has to be written to 
     */
    def private static synthesizeDeviceControlSourceFile(UposCategory category, File outputDir) {
    	for (uposMinorVersion : supportedUnifiedPOSMinorVersionRange) {
    		if (uposMinorVersion >= category.minorVersionAdded) {
		        SynthesizeHelper.generateFile(
		        	new File(outputDir, '''«category.name»Service1«uposMinorVersion».java'''), 
		        	category.deviceServiceInterfaceFor(uposMinorVersion)
		        )
    		}
    	}
    }
    
    def private static deviceServiceInterfaceFor(UposCategory category, int uposMinorVersion) {
    	val numberOfPropertiesAndMethods = 
    		category.properties.filter[minorVersionAdded == uposMinorVersion].size 
    		+ category.methods.filter[minorVersionAdded == uposMinorVersion].size
    	
	    '''
			//////////////////////////////////////////////////////////////////////
			//
			// The JavaPOS library source code is now under the CPL license, which 
			// is an OSS Apache-like license. The complete license is located at:
			//    http://www.ibm.com/developerworks/library/os-cpl.html
			//
			//////////////////////////////////////////////////////////////////////
			/////////////////////////////////////////////////////////////////////
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
			// «category.name»Service1«uposMinorVersion»
			//
			//   Interface defining all new capabilities, properties and methods
			//   that are specific to «category.humanReadableName» for release 1.«uposMinorVersion».
			//
			//   Automatically generated from «category.name»Control1«uposMinorVersion».
			//
			/////////////////////////////////////////////////////////////////////
			
			package jpos.services;

			«IF numberOfPropertiesAndMethods > 0»			
				import jpos.*;
			«ENDIF»
			
			public interface «category.name»Service1«uposMinorVersion» extends «category.superInterfaceFor(uposMinorVersion)»
			{
				«IF numberOfPropertiesAndMethods > 0»
					«category.capabilities(uposMinorVersion)»
					«category.properties(uposMinorVersion)»
					«category.methods(uposMinorVersion)»
				«ELSE»
					// Nothing new added for release 1.«uposMinorVersion»
				«ENDIF»
			}
	    '''
    }
    
    def private static superInterfaceFor(UposCategory category, int uposMinorVersion) {
    	if (uposMinorVersion == category.minorVersionAdded)
    		'BaseService, jpos.loader.JposServiceInstance'
    	else
    		'''«category.name»Service1«uposMinorVersion-1»'''
    }
	
    def private static capabilities(UposCategory category, int uposMinorVersion) {
    	val capabilitiesInThisVersion = category.properties.filter[minorVersionAdded==uposMinorVersion].filter[name.startsWith("Cap")]
    	
    	if (capabilitiesInThisVersion.size > 0)
			'''
			    // Capabilities
			    «capabilitiesInThisVersion.map[synthesizePopertyFor(uposMinorVersion)].join»
			    
			'''
		else
			''   		
    }
    
    def private static properties(UposCategory category, int uposMinorVersion) {
    	val propertiesInThisVersion = category.properties.filter[minorVersionAdded==uposMinorVersion].filter[!name.startsWith("Cap")]
    	
    	if (propertiesInThisVersion.size > 0)
			'''
			    // Properties
			    «propertiesInThisVersion.map[synthesizePopertyFor(uposMinorVersion)].join»
			    
			'''
		else
			''   		
    }

    def private static methods(UposCategory category, int uposMinorVersion) {
    	val methodsInThisVersion = category.methods.filter[minorVersionAdded==uposMinorVersion]
    	 
    	if (methodsInThisVersion.size > 0)
			'''
			    // Methods
			    «methodsInThisVersion.map[synthesizeMethodFor(uposMinorVersion)].join»
			    
			'''
		else
			''   		
    }
    
	def private static synthesizePopertyFor(UposProperty property, int uposMinorVersion) {
		if (uposMinorVersion == property.minorVersionAdded)
			'''
		    	«property.getPropertyMethod»
		    	«IF !property.readonly»
		    		«property.setPropertyMethod»
		    	«ENDIF»
			'''
		else
			''
	}
	 
	
	def private static getPropertyMethod(UposProperty property) {
		if (property.name == 'TarePriority' && property.categoryBelongingTo.name == 'Scale')
			// this property was initially misspelled and was latter added correctly only to the control interface, not the service interface
			// and therefore is not generated for here 
			''
		else if (property.javaMethod.name == 'CapTrainingMode' && property.categoryBelongingTo.name == 'ElectronicValueRW')
			// special handling of ElectronicValueRW property which lacks of the "get" prefix in the Java method
			'''
				public «property.javaPOSTypeWhiteSpaceAligned» «property.name»() throws JposException;
			'''
		else if (property.javaMethod.name == 'getCapTrainingMode' && property.categoryBelongingTo.name == 'ElectronicValueRW')
			// the later added correct "get" prefixed property is ignored two avoid double definitions in the interface
			''
		else
			'''
				public «property.javaPOSTypeWhiteSpaceAligned» get«property.name»() throws JposException;
			'''
	}
	
	def private static setPropertyMethod(UposProperty property) '''
        public void    set«property.name»(«property.javaPOSType» «property.javaMethod.parameters.get(0).name») throws JposException;
    '''
	
	def private static synthesizeMethodFor(UposMethod method, int uposVersion) {
        if (method.name == 'setTarePriority' && method.categoryBelongingTo.name == 'Scale')
            // this property was initially misspelled and was latter added correctly only to the control interface, not the service interface
            // and therefore is not generated for here 
            ''
        else if (method.minorVersionAdded == uposVersion)
			'''
			    public void    «method.name»(«method.parameterList») throws JposException;
			'''
		else
			''
	}
	
	def private static javaPOSTypeWhiteSpaceAligned(UposProperty property) {
		val alignedString = new StringBuilder(property.javaPOSType)
		while (alignedString.length < 7) alignedString.append(' ')
		return alignedString.toString
	}
	
}


