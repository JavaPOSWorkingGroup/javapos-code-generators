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
import jpos.build.UposFeature
import jpos.build.UposMethod
import jpos.build.UposModel
import jpos.build.UposProperty
import org.junit.Test

import static extension jpos.build.SynthesizeHelper.javaPOSType
import static extension jpos.build.SynthesizeHelper.javaPOSTypeAsIdentifierPart
import static jpos.build.SynthesizeHelper.CPL_LICENSE_HEADER

class JavaPOSDeviceControlTestGenerator {
    
    // adapt this if a new UnifiedPOS minor version is going to be supported
    static val currentUnfiedPOSMinorVersion = 14

    // adapt this if your javapos-controls project has another name
    static val generatedSourceDir = new File("../javapos-controls/src/test/java/jpos")
    
    
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
            omittedReadProperties = #{
                'getState',
                'getDeviceControlDescription',
                'getDeviceControlVersion'
            }
            omittedMethods = #{
                'open'
            }
        ]
    ]

    static val supportedUnifiedPOSMinorVersionRange = (2..currentUnfiedPOSMinorVersion) 
    
    /**
     * Main class for code generation.<br>
     * Currently realized as Unit test for getting a fast and convenient interactive 
     * access to the generation functionality trough the JUnit Eclipse view.  
     */
    @Test
    def void generate() {
        val uposModel = readUposModelFor('JavaPOSDeviceControlTests')
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
            new File(generatedSourceDir, '''«category.testClassName».java'''), 
            category.deviceControlTestClass
        )
    }
    
    def private static testClassName(UposCategory category) '''«category.name»Test'''
    def private static testServiceAlwaysThrowingNPEClassName(UposCategory category) '''«category.name»TestServiceAlwaysThrowingNPE'''
    def private static testServiceClassName(UposCategory category, int minorVersion) '''«category.name»TestService1«minorVersion»'''
    
    /**
     * Synthesizes the code for a particular UnifedPOS method or property passed.
     */
    def private static String deviceControlTestClass(UposCategory category) '''
        «CPL_LICENSE_HEADER»
        
        package jpos;
        
        import static org.hamcrest.CoreMatchers.instanceOf;
        import static org.hamcrest.CoreMatchers.is;
        import static org.hamcrest.CoreMatchers.notNullValue;
        import static org.hamcrest.MatcherAssert.assertThat;
        import static org.junit.Assert.*;
        
        import org.junit.After;
        import org.junit.AfterClass;
        import org.junit.Before;
        import org.junit.BeforeClass;
        import org.junit.Test;
        
        import jpos.config.JposEntryRegistry;
        import jpos.loader.JposServiceLoader;
        import jpos.services.EventCallbacks;
        
        /**
         * «category.name» device control JUnit test.
         * <br>
         * Generated through «JavaPOSDeviceControlTestGenerator.name» for JavaPOS version 1.«currentUnfiedPOSMinorVersion»
         */
        public class «category.testClassName» {
        
            private static final String OPENNAME_ALL_METHODS_THROWING_NPE = "«category.testServiceAlwaysThrowingNPEClassName»";
            private static final String OPENNAME_SERVICE_10 = "«category.testServiceClassName(category.minorVersionAdded)»";
            «(category.minorVersionAdded..currentUnfiedPOSMinorVersion).map[ minorVersion |
                '''private static final String OPENNAME_SERVICE_1«minorVersion» = "«category.testServiceClassName(minorVersion)»";'''
            ].join('\n')»
        
            /**
             * @throws java.lang.Exception
             */
            @BeforeClass
            public static void setUpBeforeClass() throws Exception {
                JposEntryRegistry registry = JposServiceLoader.getManager().getEntryRegistry();
                registry.addJposEntry(ControlsTestHelper.createJposEntry("«category.name»", OPENNAME_ALL_METHODS_THROWING_NPE, "1.«currentUnfiedPOSMinorVersion»"));
                «(category.minorVersionAdded..currentUnfiedPOSMinorVersion).map[ minorVersion | 
                    '''registry.addJposEntry(ControlsTestHelper.createJposEntry("«category.name»", OPENNAME_SERVICE_1«minorVersion», "1.«minorVersion»"));'''
                ].join('\n')»
            }
        
            /**
             * @throws java.lang.Exception
             */
            @AfterClass
            public static void tearDownAfterClass() throws Exception {
                JposEntryRegistry registry = JposServiceLoader.getManager().getEntryRegistry();
                registry.removeJposEntry(OPENNAME_ALL_METHODS_THROWING_NPE);
                «(category.minorVersionAdded..currentUnfiedPOSMinorVersion).map[ minorVersion | 
                    '''registry.removeJposEntry(OPENNAME_SERVICE_1«minorVersion»);'''
                ].join('\n')»
            }
        
            private «category.name» control;
        
            @Before
            public void setUp() throws Exception {
                this.control = new «category.name»();
            }
        
            @After
            public void tearDown() throws Exception {
                this.control = null;
            }
        
            /**
             * Test method for {@link jpos.«category.name»#createEventCallbacks()}.
             */
            @Test
            public final void testCreateEventCallbacks() {
                EventCallbacks callbacks = this.control.createEventCallbacks();
                assertThat(callbacks, is(notNullValue()));
            }
            
            «category.properties.map[testFailsWithClosedExceptionBeforeOpen].join»
            «category.methods.map[testFailsWithClosedExceptionBeforeOpen].join»
            
            «category.properties.map[testFailsWithFailureExceptionOnNPE].join»
            «category.methods.map[testFailsWithFailureExceptionOnNPE].join»
            
            «category.properties.map[testFailsOnServiceVersionBeforeAdded].join»
        }
    '''
    
    def private static testFailsOnServiceVersionBeforeAdded(UposProperty property) '''
        «IF property.minorVersionAdded > property.categoryBelongingTo.minorVersionAdded»
            @Test
            public void test«property.getMethodName»FailsOnServiceVersionBeforeAdded() {
                try {
                    this.control.open(OPENNAME_SERVICE_1«property.minorVersionAdded-1»);
                    this.control.«property.getMethodName»();
                    fail("NOSERVICE JposException expected but not thrown");
                }
                catch (JposException e) {
                    assertThat("NOSERVICE JposException expected but a different was thrown: " + e.getErrorCode(), 
                            e.getErrorCode(), is(JposConst.JPOS_E_NOSERVICE));
                }
            }
            
        «ENDIF»
        
        @Test
        public void test«property.getMethodName»CalledOnServiceVersionWhenAdded() throws Exception {
            try {
                this.control.open(OPENNAME_SERVICE_1«property.minorVersionAdded»);
                this.control.«property.getMethodName»();
            }
            catch (JposException e) {
                fail(e.getMessage());
            }
        }
        
        «if (property.minorVersionAdded < currentUnfiedPOSMinorVersion) {
            (property.minorVersionAddedButNotZero+1..currentUnfiedPOSMinorVersion)
            .map[ minorVersion |
                '''
                    @Test
                    public void testGet«property.name»CalledOnServiceVersion1«minorVersion»() {
                        try {
                            this.control.open(OPENNAME_SERVICE_1«minorVersion»);
                            this.control.get«property.name»();
                        }
                        catch (JposException e) {
                            fail(e.getMessage());
                        }
                    }
                '''
            ].join
        }»
        
        «IF !property.readonly»
            «IF property.minorVersionAdded > property.categoryBelongingTo.minorVersionAdded»
                @Test
                public void testSet«property.name»FailsOnServiceVersionBeforeAdded() {
                    try {
                        this.control.open(OPENNAME_SERVICE_1«property.minorVersionAdded-1»);
                        this.control.set«property.name»(«property.type.defaultArgument»);
                        fail("NOSERVICE JposException expected but not thrown");
                    }
                    catch (JposException e) {
                        assertThat("NOSERVICE JposException expected but a different was thrown: " + e.getErrorCode(), 
                                e.getErrorCode(), is(JposConst.JPOS_E_NOSERVICE));
                    }
                }
                
            «ENDIF»
            @Test
            public void testSet«property.name»CalledOnServiceVersionWhenAdded() throws Exception {
                try {
                    this.control.open(OPENNAME_SERVICE_1«property.minorVersionAdded»);
                    this.control.set«property.name»(«property.type.defaultArgument»);
                }
                catch (JposException e) {
                    fail(e.getMessage());
                }
            }
            
            «if (property.minorVersionAdded < currentUnfiedPOSMinorVersion) {
                (property.minorVersionAddedButNotZero+1..currentUnfiedPOSMinorVersion)
                .map[ minorVersion |
                    '''
                        @Test
                        public void testSet«property.name»CalledOnServiceVersion1«minorVersion»() {
                            try {
                                this.control.open(OPENNAME_SERVICE_1«minorVersion»);
                                this.control.set«property.name»(«property.type.defaultArgument»);
                            }
                            catch (JposException e) {
                                fail(e.getMessage());
                            }
                        }
                    '''
                ].join
            }»
        «ENDIF»
    '''
    
    def private static minorVersionAddedButNotZero(UposFeature propertyOrMethod) {
        if (propertyOrMethod.minorVersionAdded == 0) // in case of methods and properties from the BaseControl class
            return propertyOrMethod.categoryBelongingTo.minorVersionAdded
        else
            return propertyOrMethod.minorVersionAdded
    }
    
    def private static String getMethodName(UposProperty property) {
        if (property.categoryBelongingTo.name == 'ElectronicValueRW' && property.javaMethod.name == 'CapTrainingMode')
            // special case for CapTrainingMode which is missing 
            property.javaMethod.name
        else
            '''get«property.name»'''
    }
    
    def private static String setMethodName(UposProperty property) '''set«property.name»''' 
    
    def private static testFailsWithFailureExceptionOnNPE(UposProperty property) '''
        @Test
        public final void test«property.getMethodName.toFirstUpper»FailsWithFailureExceptionOnNPE() {
            try {
                this.control.open(OPENNAME_ALL_METHODS_THROWING_NPE);
                this.control.«property.getMethodName»();
                fail("FAILURE JposException expected but not thrown");
            }
            catch (JposException e) {
                assertThat("FAILURE JposException expected but a different was thrown: " + e.getErrorCode(), e.getErrorCode(), is(JposConst.JPOS_E_FAILURE));
                assertThat(e.getOrigException(), is(instanceOf(NullPointerException.class)));
            }
        }
        «IF !property.readonly»
            @Test
            public final void test«property.setMethodName.toFirstUpper»FailsWithFailureExceptionOnNPE() {
                try {
                    this.control.open(OPENNAME_ALL_METHODS_THROWING_NPE);
                    this.control.«property.setMethodName»(«property.type.defaultArgument»);
                    fail("FAILURE JposException expected but not thrown");
                }
                catch (JposException e) {
                    assertThat("FAILURE JposException expected but a different was thrown: " + e.getErrorCode(), e.getErrorCode(), is(JposConst.JPOS_E_FAILURE));
                    assertThat(e.getOrigException(), is(instanceOf(NullPointerException.class)));
                }
            }
        «ENDIF»
    '''
    
    def private static paramListAsNamePart(UposMethod method) {
        if (method.name == 'retrieveDeviceAuthenticationData')
            method.parameterTypes.map[javaPOSTypeAsIdentifierPart].join
        else
            ''
    }
    
    def private static testFailsWithFailureExceptionOnNPE(UposMethod method) '''
        @Test
        public final void test«method.name.toFirstUpper»FailsWithFailureExceptionOnNPE«method.paramListAsNamePart»() {
            try {
                this.control.open(OPENNAME_ALL_METHODS_THROWING_NPE);
                this.control.«method.name»(«method.defaultArguments»);
                fail("FAILURE JposException expected but not thrown");
            }
            catch (JposException e) {
                assertThat("FAILURE JposException expected but a different was thrown: " + e.getErrorCode(), 
                        e.getErrorCode(), is(JposConst.JPOS_E_FAILURE));
                assertThat(e.getOrigException(), is(instanceOf(NullPointerException.class)));
            }
        }
    '''
    
    def private static testFailsWithClosedExceptionBeforeOpen(UposProperty property) '''
        @Test
        public final void test«property.getMethodName.toFirstUpper»FailsWithClosedExceptionBeforeOpen() {
            try {
                this.control.«property.getMethodName»();
                fail("CLOSED JposException expected but not thrown");
            }
            catch (JposException e) {
                assertThat("CLOSED JposException expected but a different was thrown: " + e.getErrorCode(), e.getErrorCode(), is(JposConst.JPOS_E_CLOSED));
            }
        }
        «IF !property.readonly»
            @Test
            public final void test«property.setMethodName»FailsWithClosedExceptionBeforeOpen() {
                try {
                    this.control.«property.setMethodName»(«property.type.defaultArgument»);
                    fail("CLOSED JposException expected but not thrown");
                }
                catch (JposException e) {
                    assertThat("CLOSED JposException expected but a different was thrown: " + e.getErrorCode(), e.getErrorCode(), is(JposConst.JPOS_E_CLOSED));
                }
            }
        «ENDIF»
    '''

    def private static testFailsWithClosedExceptionBeforeOpen(UposMethod method) '''
        @Test
        public final void test«method.name.toFirstUpper»FailsWithClosedExceptionBeforeOpen«method.paramListAsNamePart»() {
            try {
                this.control.«method.name»(«method.defaultArguments»);
                fail("CLOSED JposException expected but not thrown");
            }
            catch (JposException e) {
                assertThat("CLOSED JposException expected but a different was thrown: " + e.getErrorCode(), e.getErrorCode(), is(JposConst.JPOS_E_CLOSED));
            }
        }
    '''
    
    def static defaultArguments(UposMethod method) {
        method.parameterTypes.map[defaultArgument].join(',')
    }
    
    def static defaultArgument(Class<?> type) {
        switch (type) {
            
        	case int: return '0'
        	case long: return '0'
        	case String: return '""'
        	case boolean: return true
        	case byte: return '(byte)0'
        	case Object: return 'new Object()'
        	
            case typeof(boolean[]): return 'new boolean[0]'
        	case typeof(byte[]): return 'new byte[0]'
            case typeof(String[]):  return 'new String[0]'  
            case typeof(int[]):     return 'new int[0]'
            case typeof(long[]):    return 'new long[0]'
            case typeof(Object[]):  return 'new Object[0]'

            case typeof(byte[][]):  return 'new byte[0][0]'
            case typeof(int[][]):     return 'new int[0][0]'
            
        	default: '''[unknown type "«type.javaPOSType»"]'''
        }
    }
    
}


