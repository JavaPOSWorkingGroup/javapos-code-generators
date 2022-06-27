package jpos.build.controls

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
                BumpBarControl115, 
                CashChangerControl115,
                CashDrawerControl115,
                CATControl115,
                CheckScannerControl115, 
                CoinDispenserControl115, 
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
        import java.lang.reflect.*;
        
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
