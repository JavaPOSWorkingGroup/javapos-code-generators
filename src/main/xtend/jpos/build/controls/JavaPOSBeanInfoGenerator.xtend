package jpos.build.controls

import java.io.File
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
                BumpBarControl114, 
                CashChangerControl114,
                CashDrawerControl114,
                CATControl114,
                CheckScannerControl114, 
                CoinDispenserControl114, 
                FiscalPrinterControl114, 
                HardTotalsControl114,
                KeylockControl114,
                LineDisplayControl114, 
                MICRControl114,
                MotionSensorControl114,
                MSRControl114,
                PINPadControl114, 
                PointCardRWControl114, 
                POSKeyboardControl114,
                POSPowerControl114,
                POSPrinterControl114, 
                RemoteOrderDisplayControl114, 
                ScaleControl114,
                ScannerControl114, 
                SignatureCaptureControl114, 
                ToneIndicatorControl114,
                BeltControl114,
                BillAcceptorControl114, 
                BillDispenserControl114, 
                CoinAcceptorControl114,
                CoinDispenserControl114,
                BiometricsControl114,
                ElectronicJournalControl114, 
                ElectronicValueRWControl114,
                GateControl114,
                ImageScannerControl114,  
                ItemDispenserControl114, 
                LightsControl114,
                RFIDScannerControl114, 
                SmartCardRWControl114
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