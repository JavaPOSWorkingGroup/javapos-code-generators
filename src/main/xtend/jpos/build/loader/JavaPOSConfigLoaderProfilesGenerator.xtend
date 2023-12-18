package jpos.build.loader

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
import jpos.build.UPOSModelReader
import jpos.build.UPOSModelReaderConfiguration
import jpos.build.UposModel
import org.junit.Test
import java.io.File
import jpos.build.UposCategory
import jpos.build.SynthesizeHelper

class JavaPOSConfigLoaderProfilesGenerator {
	
    // adapt this if your javapos-config-loader project paths has another name
    static val generatedSourceDir = new File("../javapos-config-loader/src/main/java/jpos/profile")
    
    
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
                SmartCardRWControl116
                // new in UPOS 1.16
//                DeviceMonitorControl116,
//                GestureControlControl116,
//                GraphicDisplayControl116,
//                IndividualRecognitionControl116,
//                SoundPlayerControl116,
//                SoundRecorderControl116,
//                SpeechSynthesisControl116,
//                VideoCaptureControl116,
//                VoiceRecognitionControl116                
            ]
        ]
    ]

    /**
     * Main class for code generation.<br>
     * Currently realized as Unit test for getting a fast and convenient interactive 
     * access to the generation functionality trough the JUnit Eclipse view.  
     */
    @Test
    def void generate() {
        val uposModel = readUposModelFor('JavaPOSConfigLoaderProfiles')
        uposModel.synthesize
    }
    
    /**
     * Synthesize all files for the passed UnifiedPOS model 
     */
    def private static synthesize(UposModel model) {
        generatedSourceDir.mkdirs() 
		generateJposDevCatsJavaSourceFile(model)
		generateDevCatInterfaceSourceFile(model)
		generateDevCatVisitorJavaSourceFile(model)
		generateDefaultDevCatVisitorJavaSourceFile(model)
    }
    
    def private static generateDevCatInterfaceSourceFile(UposModel uposModel) {
    	SynthesizeHelper.generateFile(
            new File(generatedSourceDir, '''DevCat.java'''), 
            uposModel.synthesizeDevCatInterfaceSource
        )
    }
    
    def private static generateJposDevCatsJavaSourceFile(UposModel uposModel) {
    	SynthesizeHelper.generateFile(
            new File(generatedSourceDir, '''JposDevCats.java'''), 
            uposModel.synthesizeJposDevCatsClass
        )
    }

    def private static generateDevCatVisitorJavaSourceFile(UposModel uposModel) {
    	SynthesizeHelper.generateFile(
            new File(generatedSourceDir, '''DevCatVisitor.java'''), 
            uposModel.synthesizeDevCatVisitorClass
        )
    }
    
    def private static generateDefaultDevCatVisitorJavaSourceFile(UposModel uposModel) {
    	SynthesizeHelper.generateFile(
            new File(generatedSourceDir, '''DefaultDevCatV.java'''), 
            uposModel.synthesizeDefaultDevCatVClass
        )
    }

	def private static devCatName(UposCategory category) {
		if (category.javaClass == jpos.PINPadControl116)
			return 'Pinpad'
		else
			category.name
	}
    
    def private static synthesizeDevCatInterfaceSource(UposModel uposModel) '''
    	package jpos.profile;
    	
    	///////////////////////////////////////////////////////////////////////////////
    	//
    	// This software is provided "AS IS".  The JavaPOS working group (including
    	// each of the Corporate members, contributors and individuals)  MAKES NO
    	// REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
    	// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED 
    	// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
    	// NON-INFRINGEMENT. The JavaPOS working group shall not be liable for
    	// any damages suffered as a result of using, modifying or distributing this
    	// software or its derivatives. Permission to use, copy, modify, and distribute
    	// the software and its documentation for any purpose is hereby granted. 
    	//
    	// The JavaPOS Config/Loader (aka JCL) is now under the CPL license, which 
    	// is an OSS Apache-like license.  The complete license is located at:
    	//    http://www.ibm.com/developerworks/library/os-cpl.html
    	//
    	///////////////////////////////////////////////////////////////////////////////
    	
    	/**
    	 * Defines an interface for JavaPOS device categories
    	 * @since 1.3 (SF 2K meeting)
    	 * @author generated by «JavaPOSConfigLoaderProfilesGenerator.name»; 
    	 *         originally created by E. Michael Maximilien (maxim@us.ibm.com) 
    	 */
    	public interface DevCat
    	{
    		//-------------------------------------------------------------------------
    		// Constants
    		//
    		
    		/** Indicates the version of JavaPOS that these DevCat apply to */
    		public static final String JPOS_VERSION_STRING = "1.15";
    	
    		//-------------------------------------------------------------------------
    		// Public methods
    		//
    	
    		/** @return the String representation of this DevCat */
    		public String toString();
    	
    		/**
    		 * Accepts a DevCat Visitor object
    		 * @param visitor the DevCat Visitor object
    		 */
    		public void accept( DevCatVisitor visitor );
    	
    		//-------------------------------------------------------------------------
    		// Inner interfaces
    		//
    		
    		«uposModel.categories?.sortBy[name].map[devCatInterface].join»
    	}
    '''
	
	def private static devCatInterface(UposCategory category) '''
		/** Defines the DevCat for «category.devCatName» */
		public interface «category.devCatName» extends DevCat {}
		
	'''

	def private static synthesizeJposDevCatsClass(UposModel uposModel) '''
		package jpos.profile;
		
		///////////////////////////////////////////////////////////////////////////////
		//
		// This software is provided "AS IS".  The JavaPOS working group (including
		// each of the Corporate members, contributors and individuals)  MAKES NO
		// REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
		// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED 
		// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
		// NON-INFRINGEMENT. The JavaPOS working group shall not be liable for
		// any damages suffered as a result of using, modifying or distributing this
		// software or its derivatives. Permission to use, copy, modify, and distribute
		// the software and its documentation for any purpose is hereby granted. 
		//
		// The JavaPOS Config/Loader (aka JCL) is now under the CPL license, which 
		// is an OSS Apache-like license.  The complete license is located at:
		//    http://www.ibm.com/developerworks/library/os-cpl.html
		//
		///////////////////////////////////////////////////////////////////////////////
		
		import java.util.*;
		
		/**
		 * Defines an interface for JavaPOS device categories
		 * @since 1.3 (SF 2K meeting)
		 * @author generated by «JavaPOSConfigLoaderProfilesGenerator.name»;
		 *         originally created by E. Michael Maximilien (maxim@us.ibm.com) 
		 */
		public class JposDevCats
		{
			//-------------------------------------------------------------------------
			// Private class constants
			//
		
			private static final Hashtable DEVCAT_TABLE = new Hashtable();
		
			//-------------------------------------------------------------------------
			// Class constants
			//
		
			public static final DevCat UNKNOWN_DEVCAT = 
											 JposDevCats.Unknown.getInstance();
		
			«uposModel.categories?.sortBy[name].map[devCatConstDef].join»
		
			//-------------------------------------------------------------------------
			// Class constants
			//
			
			/** An array of all of the JavaPOS DevCat */
			public static final DevCat[] DEVCAT_ARRAY = { 
				«uposModel.categories?.sortBy[name].map[devCatConst].join(',\n')»
			};
		
			//-------------------------------------------------------------------------
			// Static initializer
			//
			
			static
			{
				«uposModel.categories?.sortBy[name].map[devCatTableInsertion].join('\n')»
			}
			
			//-------------------------------------------------------------------------
			// Class methods
			//
		
			/**
			 * @return the DevCat for the String name passed
			 * @param devCatName the String name for this DevCat
			 */
			public static DevCat getDevCatForName( String devCatName )
			{
				if( DEVCAT_TABLE.containsKey( devCatName ) )
					return (DevCat)DEVCAT_TABLE.get( devCatName );
		
				return UNKNOWN_DEVCAT;
			}
		
			//-------------------------------------------------------------------------
			// Inner classes
			//
		
			/**
			 * Defines the super class for all DevCat
			 * @since 1.3 (SF 2K meeting)
			 * @author E. Michael Maximilien (maxim@us.ibm.com)
			 */
			public static abstract class AbstractDevCat
			implements DevCat 
			{
			    //---------------------------------------------------------------------
			    // Public overriden methods
			    //
		
			    /** @return the String representation of this DevCat */
			    public abstract String toString();
		
				/** 
				 * @return true if these two DevCat are the same JavaPOS device 
				 * category 
				 * @param obj the other object to compare to
				 */
				public boolean equals( Object obj )
				{
					if( obj == null ) return false;
		
					if( !( obj instanceof DevCat ) ) return false;
		
					return toString().equals( obj.toString() );
				}
			}
		
			/**
			 * Defines an Unknown DevCat
			 * @since 1.3 (SF 2K meeting)
			 * @author E. Michael Maximilien (maxim@us.ibm.com)
			 */
			public static class Unknown extends AbstractDevCat implements DevCat 
			{
				//---------------------------------------------------------------------
				// Ctor(s)
				//
		
				/** Make ctor package to avoid ctor */
				Unknown() {}
		
				//---------------------------------------------------------------------
				// Class methods
				//
		
				/** @return the unique instance of this class (create if necessary) */
				public static DevCat getInstance()
				{
					if( instance == null )
						instance = new JposDevCats.Unknown();
		
					return instance;
				}
		
				//---------------------------------------------------------------------
				// Public methods
				//
		
				/** @return the String representation of this DevCat */
				public String toString() { return "Unknown"; }
		
				/**
				 * Accepts a DevCat Visitor object
				 * @param visitor the DevCat Visitor object
				 */
				public void accept( DevCatVisitor visitor ) {}
		
				//---------------------------------------------------------------------
				// Class instance
				//
		
				private static DevCat instance = null;
			}
			
			«uposModel.categories?.sortBy[name].map[staticDevCatClass].join»
		}
	''' 
	
	def private static devCatConst(UposCategory category) '''«category.name.toUpperCase»_DEVCAT'''
	
	def private static devCatConstDef(UposCategory category) '''
		public static final DevCat «category.devCatConst» = 
										 JposDevCats.«category.devCatName».getInstance();
	'''
	
	def private static devCatTableInsertion(UposCategory category) '''DEVCAT_TABLE.put( «category.devCatConst».toString(), «category.devCatConst»);'''
	
	def private static staticDevCatClass(UposCategory category) '''
		/**
		 * Defines the DevCat for «category.name»
		 */
		public static class «category.devCatName» extends AbstractDevCat implements DevCat
		{		
			//---------------------------------------------------------------------
			// Ctor(s)
			//
			
			/** Make ctor package to avoid ctor */
			«category.devCatName»() {}
			
			//---------------------------------------------------------------------
			// Class methods
			//
			
			/** @return the unique instance of this class (create if necessary) */
			public static DevCat getInstance()
			{
				if( instance == null )
					instance = new JposDevCats.«category.devCatName»();
			
				return instance;
			}
			
			//---------------------------------------------------------------------
			// Public methods
			//
			
			/** @return the String representation of this DevCat */
			public String toString() { return "«category.devCatName»"; }
			
			/**
			 * Accepts a DevCat Visitor object
			 * @param visitor the DevCat Visitor object
			 */
			public void accept( DevCatVisitor visitor ) 
			{ visitor.visit«category.devCatName»( this ); }
			
			//---------------------------------------------------------------------
			// Class instance
			//
			
			private static DevCat instance = null;
		}
		
	'''
	
	def private static synthesizeDevCatVisitorClass(UposModel uposModel) '''
		package jpos.profile;
		
		///////////////////////////////////////////////////////////////////////////////
		//
		// This software is provided "AS IS".  The JavaPOS working group (including
		// each of the Corporate members, contributors and individuals)  MAKES NO
		// REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
		// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED 
		// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
		// NON-INFRINGEMENT. The JavaPOS working group shall not be liable for
		// any damages suffered as a result of using, modifying or distributing this
		// software or its derivatives. Permission to use, copy, modify, and distribute
		// the software and its documentation for any purpose is hereby granted. 
		//
		// The JavaPOS Config/Loader (aka JCL) is now under the CPL license, which 
		// is an OSS Apache-like license.  The complete license is located at:
		//    http://www.ibm.com/developerworks/library/os-cpl.html
		//
		///////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Defines a Visitor interface for the DevCat hiearchy
		 * @since 1.3 (SF 2K meeting)
		 * @author generated by «JavaPOSConfigLoaderProfilesGenerator.name»; 
		 *         originally created by E. Michael Maximilien (maxim@us.ibm.com) 
		 */
		public interface DevCatVisitor
		{
			//-------------------------------------------------------------------------
			// Public methods
			//
		
			«uposModel.categories?.sortBy[name].map[visitorMethodDefinition].join»
		}
	'''
	
	def static visitorMethodDefinition(UposCategory category) '''
		/**
		 * Visits a  «category.name» DevCat
		 * @param devCat the DevCat
		 */
		public void visit«category.devCatName»( DevCat devCat );
		
	'''
	
	def private static synthesizeDefaultDevCatVClass(UposModel uposModel) '''
		package jpos.profile;
		
		///////////////////////////////////////////////////////////////////////////////
		//
		// This software is provided "AS IS".  The JavaPOS working group (including
		// each of the Corporate members, contributors and individuals)  MAKES NO
		// REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
		// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED 
		// WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND 
		// NON-INFRINGEMENT. The JavaPOS working group shall not be liable for
		// any damages suffered as a result of using, modifying or distributing this
		// software or its derivatives. Permission to use, copy, modify, and distribute
		// the software and its documentation for any purpose is hereby granted. 
		//
		// The JavaPOS Config/Loader (aka JCL) is now under the CPL license, which 
		// is an OSS Apache-like license.  The complete license is located at:
		//    http://www.ibm.com/developerworks/library/os-cpl.html
		//
		///////////////////////////////////////////////////////////////////////////////
		
		/**
		 * Defines a default a Visitor interface for the DevCat hiearchy
		 * @since 1.3 (SF 2K meeting)
		 * @author generated by «JavaPOSConfigLoaderProfilesGenerator.name»;
		 *         originally created by E. Michael Maximilien (maxim@us.ibm.com) 
		 * @author E. Michael Maximilien (maxim@us.ibm.com)
		 */
		public class DefaultDevCatV implements DevCatVisitor
		{
			//-------------------------------------------------------------------------
			// Public methods
			//
		
			«uposModel.categories?.sortBy[name].map[visitorMethodImplementation].join»
		}
	'''
	
	def static visitorMethodImplementation(UposCategory category) '''
		/**
		 * Visits a «category.name» DevCat
		 * @param devCat the DevCat
		 */
		public void visit«category.devCatName»( DevCat devCat ) {}
		
	'''
	
}