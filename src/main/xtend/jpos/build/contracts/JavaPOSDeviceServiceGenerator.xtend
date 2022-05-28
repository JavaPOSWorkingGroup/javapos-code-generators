package jpos.build.contracts

import java.io.File
import jpos.BeltControl115
import jpos.BillAcceptorControl115
import jpos.BillDispenserControl115
import jpos.BiometricsControl115
import jpos.BumpBarControl115
import jpos.CATControl115
import jpos.CashChangerControl115
import jpos.CashDrawerControl115
import jpos.CheckScannerControl115
import jpos.CoinAcceptorControl115
import jpos.CoinDispenserControl115
import jpos.ElectronicJournalControl115
import jpos.ElectronicValueRWControl115
import jpos.FiscalPrinterControl115
import jpos.GateControl115
import jpos.HardTotalsControl115
import jpos.ImageScannerControl115
import jpos.ItemDispenserControl115
import jpos.KeylockControl115
import jpos.LightsControl115
import jpos.LineDisplayControl115
import jpos.MICRControl115
import jpos.MSRControl115
import jpos.MotionSensorControl115
import jpos.PINPadControl115
import jpos.POSKeyboardControl115
import jpos.POSPowerControl115
import jpos.POSPrinterControl115
import jpos.PointCardRWControl115
import jpos.RFIDScannerControl115
import jpos.RemoteOrderDisplayControl115
import jpos.ScaleControl115
import jpos.ScannerControl115
import jpos.SignatureCaptureControl115
import jpos.SmartCardRWControl115
import jpos.ToneIndicatorControl115
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
    static val currentUnfiedPOSMinorVersion = 15
    
    // adapt this for controlling the version range of the to be generated service interface files 
	static val supportedUnifiedPOSMinorVersionRange = (2..currentUnfiedPOSMinorVersion)
	
	// adapt this if your javapos-contracts project has another name
    static val generatedSourceDir = new File("../javapos-contracts/src/main/java/jpos/services")
    	
    
    extension UPOSModelReader modelReader = new UPOSModelReader => [
        configuration = new UPOSModelReaderConfiguration => [
            supportedCategories = #
            [
                BumpBarControl115, 
                CashChangerControl115,
                CashDrawerControl115,
                CATControl115,
                CheckScannerControl115, 
                FiscalPrinterControl115, 
                HardTotalsControl115,
                KeylockControl115,
                LineDisplayControl115, 
                MICRControl115,
                MotionSensorControl115,
                MSRControl115,
                PINPadControl115, 
                PointCardRWControl115, 
                POSKeyboardControl115,
                POSPowerControl115,
                POSPrinterControl115, 
                RemoteOrderDisplayControl115, 
                ScaleControl115,
                ScannerControl115, 
                SignatureCaptureControl115, 
                ToneIndicatorControl115,
                BeltControl115,
                BillAcceptorControl115, 
                BillDispenserControl115, 
                CoinAcceptorControl115,
                CoinDispenserControl115,
                BiometricsControl115,
                ElectronicJournalControl115, 
                ElectronicValueRWControl115,
                GateControl115,
                ImageScannerControl115,  
                ItemDispenserControl115, 
                LightsControl115,
                RFIDScannerControl115, 
                SmartCardRWControl115
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


