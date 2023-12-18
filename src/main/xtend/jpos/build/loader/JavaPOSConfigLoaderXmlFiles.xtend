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

class JavaPOSConfigLoaderXmlFiles {
	
	// adapt this if a new UnifiedPOS minor version is going to be supported
    static val currentUnfiedPOSMinorVersion = 15
	
    // adapt this if your javapos-config-loader project paths has another name
    static val generatedSourceDir = new File("../javapos-config-loader/src/main/resources/jpos/res/")
    
    
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
        ]
    ]

    /**
     * Main class for code generation.<br>
     * Currently realized as Unit test for getting a fast and convenient interactive 
     * access to the generation functionality trough the JUnit Eclipse view.  
     */
    @Test
    def void generate() {
        val uposModel = readUposModelFor('JavaPOSConfigLoaderXmlFiles')
        uposModel.synthesize
    }
    
    /**
     * Synthesize all files for the passed UnifiedPOS model 
     */
    def private static synthesize(UposModel model) {
        generatedSourceDir.mkdirs() 
		generateXsdSchemaFile(model)
		generateDtdSchemaFile(model)
		generateDtdProfileSchemaFile(model)
    }
    
    def private static generateXsdSchemaFile(UposModel uposModel) {
    	SynthesizeHelper.generateFile(
            new File(generatedSourceDir, '''jcl.xsd'''), 
            uposModel.synthesizeXsdSchemaSource
        )
    }
	
    def private static generateDtdSchemaFile(UposModel uposModel) {
    	SynthesizeHelper.generateFile(
            new File(generatedSourceDir, '''jcl.dtd'''), 
            uposModel.synthesizeDtdSchemaSource
        )
    }
	
    def private static generateDtdProfileSchemaFile(UposModel uposModel) {
    	SynthesizeHelper.generateFile(
            new File(generatedSourceDir, '''jcl_profile.dtd'''), 
            uposModel.synthesizeDtdProfileSchemaSource
        )
    }
	
	def private static synthesizeXsdSchemaSource(UposModel uposModel) '''
		<?xml version="1.0" encoding="UTF-8"?>
		<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
		
		<!--
		            targetNamespace="http://www.javapos.com/2002/jcl">
				    xmlns="http://www.javapos.com/2002/jcl">
		-->	
			<!-- generated by «JavaPOSConfigLoaderXmlFiles.name» -->	    
		    
		    <!-- Root JposEntries xsd:element definition -->
		    <xsd:complexType name="JposEntriesType">
			    <xsd:sequence>
		                <xsd:element name="JposEntry" type="JposEntryType" minOccurs="0" maxOccurs="unbounded"/>
		    	</xsd:sequence>       
		    </xsd:complexType>
		    
		    <xsd:element name="JposEntries" type="JposEntriesType"/>
		    
		    <!-- All other xsd:complexType definitions -->
		    <xsd:complexType name="JposEntryType">
		        <xsd:sequence>
		            <xsd:element name="creation" type="CreationType" minOccurs="1" maxOccurs="1"/>
		            <xsd:element name="vendor" type="VendorType" minOccurs="1" maxOccurs="1"/>
		            <xsd:element name="jpos" type="JposType" minOccurs="1" maxOccurs="1"/>
		            <xsd:element name="product" type="ProductType" minOccurs="1" maxOccurs="1"/>
		            <xsd:element name="prop" type="PropType" minOccurs="0" maxOccurs="unbounded"/>
		        </xsd:sequence>
		        <xsd:attribute name="logicalName" type="xsd:string" use="required"/>
		    </xsd:complexType>
		    
		    <xsd:complexType name="CreationType">
		        <xsd:attribute name="factoryClass" type="xsd:string" use="required"/>
		        <xsd:attribute name="serviceClass" type="xsd:string" use="required"/>
		    </xsd:complexType>
		    
		    <xsd:complexType name="VendorType">
		        <xsd:attribute name="name" type="xsd:string" use="required"/>
		        <xsd:attribute name="url" type="xsd:anyURI" use="required"/>
		    </xsd:complexType>
		
		    <xsd:complexType name="JposType">
		        <xsd:attribute name="category" type="JposDevCatType" use="required"/>
		        <xsd:attribute name="version" type="VersionType" use="required"/>
		    </xsd:complexType>
		
		    <xsd:complexType name="ProductType">
		        <xsd:attribute name="description" type="xsd:string" use="required"/>
		        <xsd:attribute name="name" type="xsd:string" use="required"/>
		        <xsd:attribute name="url" type="xsd:anyURI" use="required"/>
		    </xsd:complexType>
		
		    <xsd:complexType name="PropType">
		        <xsd:attribute name="name" type="xsd:string" use="required"/>
		        <xsd:attribute name="value" type="xsd:string" use="required"/>
		        <xsd:attribute name="type" type="PropTypeType" use="optional"/>
		    </xsd:complexType>
		                
		    <!-- All xsd:simpleType definitions -->        
		    <xsd:simpleType name="JposDevCatType">
		        <xsd:restriction base="xsd:string">
		            «uposModel.categories?.sortBy[name].map[xsdEnumeration].join('\n')»
		        </xsd:restriction>
		    </xsd:simpleType>
		    
		    <xsd:simpleType name="PropTypeType">
		        <xsd:restriction base="xsd:string">
		            <xsd:enumeration value="String"/>
		            <xsd:enumeration value="Boolean"/>
		            <xsd:enumeration value="Character"/>
		            <xsd:enumeration value="Integer"/>
		            <xsd:enumeration value="Long"/>
		            <xsd:enumeration value="Byte"/>
		            <xsd:enumeration value="Short"/>
		            <xsd:enumeration value="Double"/>
		            <xsd:enumeration value="Float"/>
		            <xsd:enumeration value="URI"/>            
		        </xsd:restriction>
		    </xsd:simpleType>
		    
		    <xsd:simpleType name="VersionType">
		        <xsd:restriction base="xsd:string">
		            <xsd:enumeration value="1.4a"/>
		        	«(5..currentUnfiedPOSMinorVersion).map[xsdUposVersionEnumeration].join('\n')»
		        </xsd:restriction>
		    </xsd:simpleType>
		</xsd:schema>
	'''
	
	def private static xsdEnumeration(UposCategory category) '''<xsd:enumeration value="«category.name»"/>'''
	
	def private static xsdUposVersionEnumeration(int minorVersion) '''<xsd:enumeration value="1.«minorVersion»"/>''' 
	
	def private static synthesizeDtdSchemaSource(UposModel uposModel) '''
		<?xml encoding="UTF-8"?>
		
		<!-- Revision: 1 2.0.0 http://www.nrf-arts.com/JavaPOS/JCL/jcl.dtd, docs, xml4j2, xml4j2_0_13  -->
		
		<!-- 
		     This is the DTD for all JCL (JavaPOS Config/Loader) entries.  It defines
		     the content necessary for all JCL entries in their XML file.  Please see the
		     example XML files in the release as well as the JCL documentation for details
		     on how to create your own XML files that are valid for this DTD.  You may also
		     use the JCL editor to create these files, as long as the JCL instalation is 
		     setup for XML (instead of serialized or CFG).
		     @author generated by «JavaPOSConfigLoaderXmlFiles.name»
		     originally created by E. Michael Maximilien (maxim@us.ibm.com)
		     @since 1.2
		-->
		     
		<!ELEMENT JposEntries (JposEntry)*>
		
		<!ELEMENT JposEntry (creation, vendor, jpos, product, prop+)>
		<!ATTLIST JposEntry logicalName CDATA #REQUIRED>
		
		<!ELEMENT creation (#PCDATA)>
		<!ELEMENT vendor (#PCDATA)>
		<!ELEMENT jpos (#PCDATA)>
		<!ELEMENT product (#PCDATA)>
		<!ELEMENT prop (#PCDATA)>
		
		<!ATTLIST creation
		          factoryClass CDATA #REQUIRED
		          serviceClass CDATA #REQUIRED>
		          
		<!ATTLIST vendor
		          name CDATA #REQUIRED
		          url CDATA #IMPLIED>
		          
		<!ATTLIST jpos
		          version CDATA #REQUIRED
		          category ( 
		              «uposModel.categories?.sortBy[name].map[name].join(' | \n')»
		          ) #REQUIRED>
		                     
		<!ATTLIST product 
		          name CDATA #REQUIRED
		          description CDATA #REQUIRED
		          url CDATA #IMPLIED>
		          
		<!-- NOTE on the type attribute.  
		     This was added after the first release and therefore to maintain 
		     compatibility, it is defined as #IMPLIED so that it does not need 
		     to be specified and the default type for attributes with no type
		     is String.  for instance:
		               <prop name="propName" value="1234"/> 
		     is of type String and the "1234" value is kept as a String in the
		     JposEntry.  If you want the "1234" to be converted to an integer 
		     for instance then you must use the type attribute as follow:
		               <prop name="propName" value="1234" type="Integer"/> 
		-->
		<!ATTLIST prop
		          name CDATA #REQUIRED
		          value CDATA #REQUIRED
		          type ( String | Boolean | Byte | Character | Double | Float | 
		                 Integer | Long | Short ) #IMPLIED>

	'''
	
	def private static synthesizeDtdProfileSchemaSource(UposModel uposModel) '''
		<?xml encoding="UTF-8"?>
		
		<!-- Revision: 0 1.5 http://www.nrf-arts.com/JavaPOS/JCL/jcl_profile.dtd, docs, xerces, xerces1_1_1  -->
		
		<!ELEMENT Profile (ProfileInfo, JposEntryInfo*)>
		
		<!ELEMENT ProfileInfo EMPTY>
		
		<!ELEMENT JposEntryInfo (StandardProp*, RequiredProp*, OptionalProp*)>
		
		<!ELEMENT StandardProp (PropInfo)*>
		<!ELEMENT RequiredProp (PropInfo)*>
		<!ELEMENT OptionalProp (PropInfo)*>
		
		<!ELEMENT PropInfo (Tooltip?, PropValue+, PropViewer?)>
		<!ELEMENT PropValue (Tooltip?, Value+)>
		<!ELEMENT PropViewer (#PCDATA)>
		<!ELEMENT Tooltip (#PCDATA)>
		<!ELEMENT Value (#PCDATA)>
		
		<!ATTLIST Profile
		          name CDATA #REQUIRED>
		
		<!ATTLIST ProfileInfo
		          version CDATA #REQUIRED
		          vendorName CDATA #REQUIRED
		          vendorUrl CDATA #REQUIRED
		          description CDATA #IMPLIED>
		          
		<!ATTLIST JposEntryInfo
		          name CDATA #REQUIRED 
		          jposVersion CDATA #REQUIRED
		          deviceCategory ( 
		              «uposModel.categories?.sortBy[name].map[name].join(' | \n')»
		          ) #REQUIRED
		          imageFile CDATA #IMPLIED>
		
		<!ATTLIST PropInfo
		          name CDATA #REQUIRED>
		
		<!ATTLIST PropValue
		          type ( booleanValue | stringValue | integerValue | charValue | listValue ) #REQUIRED
		          choice ( one | multiple | fixed ) #IMPLIED
		          default CDATA #IMPLIED>
		          
		<!ATTLIST PropViewer
		          className CDATA #REQUIRED
		          tooltip CDATA #IMPLIED
		          propValueType ( booleanValue | stringValue | integerValue | 
		                          charValue | listValue ) #REQUIRED>
	'''
}