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
import jpos.build.UposModel
import jpos.build.UposProperty
import org.junit.Test

class JavaPOSBeanInfoGenerator {
    
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
                'getState',
                
                // will already be handled by getCapTrainigMode 
                'CapTrainingMode'
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

    /**
     * Main class for code generation.<br>
     * Currently realized as Unit test for getting a fast and convenient interactive 
     * access to the generation functionality trough the JUnit Eclipse view.  
     */
    @Test
    def void generate() {
        val uposModel = readUposModelFor('JavaPOSInfoBeans')
        uposModel.synthesize
    }
    
    /**
     * Synthesize all files for the passed UnifiedPOS model 
     */
    def private static synthesize(UposModel model) {
       generatedSourceDir.mkdirs() 
        model.categories?.forEach[synthesizeBeanInfoSourceFile]
    }
    
    
    /**
     * Synthesizes a java source code file for the given category and writes it to the given directory.
     * @param category the UnifiedPOS category as returned by {@link UposModelreader} code has to be synthesized for
     * @param outputDir the directory the java file has to be written to 
     */
    def private static synthesizeBeanInfoSourceFile(UposCategory category) {
        SynthesizeHelper.generateFile(
            new File(generatedSourceDir, '''«category.name»BeanInfo.java'''), 
            category.beanInfoClass
        )
    }
    
    /**
     * Synthesizes the code for a particular UnifedPOS method or property passed.
     */
    def private static String beanInfoClass(UposCategory category) '''
        //////////////////////////////////////////////////////////////////////
        //
        // The JavaPOS library source code is now under the CPL license, which 
        // is an OSS Apache-like license. The complete license is located at:
        //    http://www.ibm.com/developerworks/library/os-cpl.html
        //
        //////////////////////////////////////////////////////////////////////
        //------------------------------------------------------------------------------
        //
        // THIS SOFTWARE IS PROVIDED AS IS. THE JAVAPOS WORKING GROUP MAKES NO
        // REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE,
        // EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
        // WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR
        // NON-INFRINGEMENT.  INDIVIDUAL OR CORPORATE MEMBERS OF THE JAVAPOS
        // WORKING GROUP SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED AS A RESULT
        // OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
        //
        // «category.name»BeanInfo.java - Bean information for the JavaPOS «category.name»
        //    device control
        //
        //------------------------------------------------------------------------------
        
        package jpos;
        
        import java.beans.*;
        
        public class «category.name»BeanInfo
          extends SimpleBeanInfo
        {
            public BeanDescriptor getBeanDescriptor()
            {
                return new BeanDescriptor(jpos.«category.name».class);
            }
        
            public PropertyDescriptor makeProperty(String propertyName)
                throws IntrospectionException
            {
                return new PropertyDescriptor(propertyName, jpos.«category.name».class);
            }
        
            public PropertyDescriptor[] getPropertyDescriptors()
            {
                try
                {
                    PropertyDescriptor[] properties =
                    {
                        // Capabilities
                        «category.properties?.filter[name.startsWith('Cap')].map[makeProperty]?.join(',\n')»«category.properties?.filter[!name.startsWith('Cap')].size > 0 ? ',':''»
                        
                        // Properties
                        «category.properties?.filter[!name.startsWith('Cap')].map[makeProperty]?.join(',\n')»
                    };
        
                    return properties;
                }
                catch(Exception e)
                {
                    return super.getPropertyDescriptors();
                }
            }
        
            public EventSetDescriptor makeEvent(String eventName)
                throws IntrospectionException, ClassNotFoundException
            {
                String listener = "jpos.events." + eventName + "Listener";
                return new EventSetDescriptor(jpos.«category.name».class,
                                              eventName,
                                              Class.forName(listener),
                                              eventName + "Occurred");
            }
        
            public EventSetDescriptor[] getEventSetDescriptors()
            {
                try
                {
                    EventSetDescriptor[] events =
                    {
                        «category.events?.map[makeEvent].join(',\n')»
                    };
                    
                    return events;
                }
                catch(Exception e)
                {
                    return super.getEventSetDescriptors();
                }
            }
        }
    '''
    
    def private static makeProperty(UposProperty property) '''makeProperty("«property.name»")'''
    
    def private static makeEvent(UposEvent event) '''makeEvent("«event.name»")'''
    
    
}
