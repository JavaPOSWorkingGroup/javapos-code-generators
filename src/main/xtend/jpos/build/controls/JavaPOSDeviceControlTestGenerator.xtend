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
import jpos.build.UposFeature
import jpos.build.UposMethod
import jpos.build.UposModel
import jpos.build.UposProperty
import org.junit.Test

import static extension jpos.build.SynthesizeHelper.javaPOSType
import static extension jpos.build.SynthesizeHelper.javaPOSTypeAsIdentifierPart
import static extension jpos.build.SynthesizeHelper.parameterList
import static jpos.build.SynthesizeHelper.CPL_LICENSE_HEADER
import static extension jpos.build.SynthesizeHelper.zeroPreceded
import jpos.build.UposEvent

class JavaPOSDeviceControlTestGenerator {
    
    // adapt this if a new UnifiedPOS minor version is going to be supported
    static val currentUnfiedPOSMinorVersion = 15

    // adapt this if your javapos-controls project has another name
    static val generatedSourceDir = new File("../javapos-controls/src/test/java/jpos")
    
    
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
            omittedReadProperties = #{
                'getState',
                'getDeviceControlDescription',
                'getDeviceControlVersion',
                'getDeviceServiceVersion'
            }
            omittedMethods = #{
                'open'
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
        val uposModel = readUposModelFor('JavaPOSDeviceControlTests')
        uposModel.synthesize
    }
    
    /**
     * Synthesize all files for the passed UnifiedPOS model 
     */
    def private static synthesize(UposModel model) {
       generatedSourceDir.mkdirs() 
        model.categories?.forEach[synthesizeDeviceControlSourceFile]
        model.categories?.forEach[synthesizeTestDeviceServiceFiles]
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
    def private static testServiceRethrowingJposExceptionClassName(UposCategory category) '''«category.name»TestServiceRethrowingJposException'''
    def private static testServiceClassName(UposCategory category, int minorVersion) '''«category.name»TestService1«minorVersion»'''
    static val propertyNameReturningVersionTooLarge = 'returnVersionTooLarge'
    static val propertyNameThrowingNPEOnGetDSVersion = 'throwingNPEOnGetDSVersion'
    
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
        
        import java.util.ArrayList;
        import java.util.List;
        import java.util.concurrent.atomic.AtomicInteger;
        
        import org.junit.After;
        import org.junit.AfterClass;
        import org.junit.Before;
        import org.junit.BeforeClass;
        import org.junit.Test;
        
        import jpos.config.JposEntryRegistry;
        import jpos.config.simple.SimpleEntry;
        import jpos.loader.JposServiceLoader;
        import jpos.services.EventCallbacks;
        import jpos.events.*;
        
        /**
         * «category.name» device control JUnit test.
         * <br>
         * Generated through «JavaPOSDeviceControlTestGenerator.name» for JavaPOS version 1.«currentUnfiedPOSMinorVersion»
         */
        public class «category.testClassName» {
        
            private static final String SERVICE_ALL_METHODS_THROWING_NPE = "«category.testServiceAlwaysThrowingNPEClassName»";
            private static final String SERVICE_ALL_METHODS_RETHROWING_JPOSEXCEPTION = "«category.testServiceRethrowingJposExceptionClassName»";
            «(category.minorVersionAdded..currentUnfiedPOSMinorVersion).map[ minorVersion |
                '''private static final String SERVICE_1«minorVersion» = "«category.testServiceClassName(minorVersion)»";'''
            ].join('\n')»
            
            private static final String OPENNAME_WITH_NOT_EXISTING_SERVICECLASS = "OpenNameWithNotExistingServiceClass";
            private static final String OPENNAME_ALL_METHODS_THROWING_NPE = SERVICE_ALL_METHODS_THROWING_NPE;
            private static final String OPENNAME_ALL_METHODS_RETHROWING_JPOSEXCEPTION = SERVICE_ALL_METHODS_RETHROWING_JPOSEXCEPTION;
            private static final String OPENNAME_THROWING_NPE_ON_GETDSVERSION = "CashDrawerTestServiceThrowingNPEOnGetDSVersion";
            
            private static final String OPENNAME_SERVICE_10 = SERVICE_1«category.minorVersionAdded»;
            «(category.minorVersionAdded..currentUnfiedPOSMinorVersion).map[ minorVersion |
                '''private static final String OPENNAME_SERVICE_1«minorVersion» = SERVICE_1«minorVersion»;'''
            ].join('\n')»
            
            «(category.minorVersionAdded..currentUnfiedPOSMinorVersion-1).map[ minorVersion |
                '''private static final String OPENNAME_SERVICE_1«minorVersion»_RETURNING_VERSION_TOO_LARGE = "«category.testServiceClassName(minorVersion)»ReturningVersionTooLarge";'''
            ].join('\n')»
            
            /**
             * @throws java.lang.Exception
             */
            @BeforeClass
            public static void setUpBeforeClass() throws Exception {
                JposEntryRegistry registry = JposServiceLoader.getManager().getEntryRegistry();
                
                registry.addJposEntry(ControlsTestHelper.createJposEntry("«category.name»", OPENNAME_WITH_NOT_EXISTING_SERVICECLASS, "1.«currentUnfiedPOSMinorVersion»", "NotExistingServiceClass"));
                registry.addJposEntry(ControlsTestHelper.createJposEntry("«category.name»", OPENNAME_ALL_METHODS_THROWING_NPE, "1.«currentUnfiedPOSMinorVersion»", SERVICE_ALL_METHODS_THROWING_NPE));
                registry.addJposEntry(ControlsTestHelper.createJposEntry("«category.name»", OPENNAME_ALL_METHODS_RETHROWING_JPOSEXCEPTION, "1.«currentUnfiedPOSMinorVersion»", SERVICE_ALL_METHODS_RETHROWING_JPOSEXCEPTION));
                registry.addJposEntry(ControlsTestHelper.createJposEntry("«category.name»", OPENNAME_THROWING_NPE_ON_GETDSVERSION, "1.1«currentUnfiedPOSMinorVersion»", SERVICE_1«currentUnfiedPOSMinorVersion», new SimpleEntry.Prop("throwingNPEOnGetDSVersion", "")));
                
                «(category.minorVersionAdded..currentUnfiedPOSMinorVersion).map[ minorVersion | 
                    '''registry.addJposEntry(ControlsTestHelper.createJposEntry("«category.name»", OPENNAME_SERVICE_1«minorVersion», "1.«minorVersion»", SERVICE_1«minorVersion»));'''
                ].join('\n')»
                
                «(category.minorVersionAdded..currentUnfiedPOSMinorVersion-1).map[ minorVersion | 
                    '''registry.addJposEntry(ControlsTestHelper.createJposEntry("«category.name»", OPENNAME_SERVICE_1«minorVersion»_RETURNING_VERSION_TOO_LARGE, "1.«minorVersion»", SERVICE_1«minorVersion», new SimpleEntry.Prop("«propertyNameReturningVersionTooLarge»", "")));'''
                ].join('\n')»
                
            }
            
            /**
             * @throws java.lang.Exception
             */
            @AfterClass
            public static void tearDownAfterClass() throws Exception {
                JposEntryRegistry registry = JposServiceLoader.getManager().getEntryRegistry();
                
                registry.removeJposEntry(OPENNAME_ALL_METHODS_THROWING_NPE);
                registry.removeJposEntry(OPENNAME_ALL_METHODS_RETHROWING_JPOSEXCEPTION);
                registry.removeJposEntry(OPENNAME_THROWING_NPE_ON_GETDSVERSION);
                
                «(category.minorVersionAdded..currentUnfiedPOSMinorVersion).map[ minorVersion | 
                    '''registry.removeJposEntry(OPENNAME_SERVICE_1«minorVersion»);'''
                ].join('\n')»
                
                «(category.minorVersionAdded..currentUnfiedPOSMinorVersion-1).map[ minorVersion | 
                    '''registry.removeJposEntry(OPENNAME_SERVICE_1«minorVersion»_RETURNING_VERSION_TOO_LARGE);'''
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
            
            @Test
            public void testOpenTwice() throws Exception {
                try {
                    this.control.open(OPENNAME_SERVICE_1«currentUnfiedPOSMinorVersion»);
                    try {
                        this.control.open(OPENNAME_SERVICE_1«currentUnfiedPOSMinorVersion»);
                        fail("ILLEGAL exception expected but not thrown");
                    }
                    catch (JposException e) {
                        assertThat(e.getErrorCode(), is(JposConst.JPOS_E_ILLEGAL));
                    }
                }
                catch (JposException e) {
                    fail(e.getMessage());
                }
            }
            
            @Test
            public void testOpenNotExistingDevice() throws Exception {
                try {
                    this.control.open("NOT_EXISTING_OPENNAME");
                    fail("ILLEGAL exception expected but not thrown");
                }
                catch (JposException e) {
                    assertThat(e.getErrorCode(), is(JposConst.JPOS_E_NOEXIST));
                }
            }
            
            @Test
            public void testOpenNotExistingServiceClass() throws Exception {
                try {
                    this.control.open(OPENNAME_WITH_NOT_EXISTING_SERVICECLASS);
                    fail("ILLEGAL exception expected but not thrown");
                }
                catch (JposException e) {
                    assertThat(e.getErrorCode(), is(JposConst.JPOS_E_NOSERVICE));
                }
            }
            
            @Test
            public void testGetStateBeforeOpen() throws Exception {
                assertThat(this.control.getState(), is(JposConst.JPOS_S_CLOSED));
            }
            
            @Test
            public void testGetStateAfterOpen() throws Exception {
                try {
                    this.control.open(OPENNAME_SERVICE_1«currentUnfiedPOSMinorVersion»);
                    assertThat(this.control.getState(), is(JposConst.JPOS_S_IDLE));
                }
                catch (JposException e) {
                    fail(e.getMessage());
                }
            }
            
            @Test
            public void testGetDeviceServiceBeforeOpen() throws Exception {
                try {
                    this.control.getDeviceServiceVersion();
                    fail("CLOSED JposException expected but not thrown");
                }
                catch (JposException e) {
                    assertThat("CLOSED JposException expected but a different was thrown: " + e.getErrorCode(), 
                            e.getErrorCode(), is(JposConst.JPOS_E_CLOSED));
                }
            }
            
            @Test
            public void testGetDeviceControlDescription() throws Exception {
                assertThat(this.control.getDeviceControlDescription(), is("JavaPOS «category.name» Device Control"));
            }
            
            @Test
            public void testDeviceControlVersion() throws Exception {
                assertThat(this.control.getDeviceControlVersion(), is(10«currentUnfiedPOSMinorVersion.zeroPreceded»000));
            }
            
            @Test
            public final void testOpenFailsOnGetDeviceVersionWithFailureExceptionOnNPE() {
                try {
                    this.control.open(OPENNAME_THROWING_NPE_ON_GETDSVERSION);
                    fail("FAILURE JposException expected but not thrown");
                }
                catch (JposException e) {
                    assertThat("FAILURE JposException expected but a different was thrown: " + e.getErrorCode(), 
                            e.getErrorCode(), is(JposConst.JPOS_E_FAILURE));
                    assertThat(e.getOrigException(), is(instanceOf(NullPointerException.class)));
                }
            }
            
            «category.properties.map[testFailsWithClosedExceptionBeforeOpen].join('\n')»
            
            «category.methods.map[testFailsWithClosedExceptionBeforeOpen].join('\n')»
            
            «category.properties.map[testFailsWithFailureExceptionOnNPE].join('\n')»
            
            «category.methods.map[testFailsWithFailureExceptionOnNPE].join('\n')»
            
            «category.properties.map[testRethrowsJposException].join('\n')»
            
            «category.methods.map[testRethrowsJposException].join('\n')»
            
            «(category.minorVersionAdded..currentUnfiedPOSMinorVersion).map[ minorVersion |
                '''
                    @Test
                    public final void testGetDeviceVersion1«minorVersion»() {
                        try {
                            this.control.open(OPENNAME_SERVICE_1«minorVersion»);
                            assertThat(this.control.getDeviceServiceVersion(), is(10«minorVersion.zeroPreceded»000));
                        }
                        catch (JposException e) {
                            fail("«category.name».getDeviceServiceVersion() failed with " + e.getMessage());
                        }
                    }
                '''
            ].join('\n')»
            
            «(category.minorVersionAdded..currentUnfiedPOSMinorVersion-1).map[ minorVersion |
                '''
                        @Test
                        public void testOpenOnService1«minorVersion»ReturningVersionTooLarge() {
                            try {
                                this.control.open(OPENNAME_SERVICE_1«minorVersion»_RETURNING_VERSION_TOO_LARGE);
                                fail("NOSERVICE exception expected but not thrown");
                            }
                            catch (JposException e) {
                                assertThat(e.getErrorCode(), is(JposConst.JPOS_E_NOSERVICE));
                            }
                        }
                '''
            ].join('\n')»
            «category.properties.map[testFailsOnServiceWrongServiceVersion].join('\n')»
            
            «category.methods.map[testFailsOnWrongServiceVersion].join('\n')»
            
            «category.events.map[testEventDelivery].join('\n')»
        }
    '''
    
    def static testEventDelivery(UposEvent event) '''
        @Test
        public void test«event.name»EventDelivery() {
            final int numberOfListeners = 5;
            final AtomicInteger remainingEventsToReceive = new AtomicInteger(numberOfListeners); // no concurrency, just boxed decrement is used 
            List<«event.name»Listener> listeners = new ArrayList<«event.name»Listener>();
            
            try {
                this.control.open(OPENNAME_SERVICE_1«currentUnfiedPOSMinorVersion»);
                
                for (int i = 0; i < numberOfListeners; i++) {
                    «event.name»Listener listener = new «event.name»Listener() {
                        @Override
                        public void «event.name.toFirstLower»Occurred(«event.name»Event e) {
                            remainingEventsToReceive.decrementAndGet();
                        }
                    };
                    this.control.add«event.name»Listener(listener);
                    listeners.add(listener);
                }
                
                this.control.directIO(«event.directIOSendingCommand», null, null);
                assertThat("not all listener received «event.name»Events", 
                        remainingEventsToReceive.get(), is(0));
                
                for («event.name»Listener listener : listeners) {
                    this.control.remove«event.name»Listener(listener);
                }
            }
            catch (JposException e) {
                fail(e.getMessage());
            }
        }
    '''
    
    def private static directIOSendingCommand(UposEvent event) '''ControlsTestHelper.SEND_«event.name.toUpperCase»_EVENT'''
    
    def private static testFailsOnServiceWrongServiceVersion(UposProperty property) '''
        «IF property.minorVersionAdded > property.categoryBelongingTo.minorVersionAdded»
            @Test
            public void test«property.getMethodName.toFirstUpper»FailsOnServiceVersionBeforeAdded() {
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
        public void test«property.getMethodName.toFirstUpper»CalledOnServiceVersionWhenAdded() throws Exception {
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
                    public void test«property.getMethodName.toFirstUpper»CalledOnServiceVersion1«minorVersion»() {
                        try {
                            this.control.open(OPENNAME_SERVICE_1«minorVersion»);
                            this.control.«property.getMethodName»();
                        }
                        catch (JposException e) {
                            fail(e.getMessage());
                        }
                    }
                '''
            ].join('\n')
        }»
        
        «IF !property.readonly»
            «IF property.minorVersionAdded > property.categoryBelongingTo.minorVersionAdded»
                @Test
                public void test«property.setMethodName.toFirstUpper»FailsOnServiceVersionBeforeAdded() {
                    try {
                        this.control.open(OPENNAME_SERVICE_1«property.minorVersionAdded-1»);
                        this.control.«property.setMethodName»(«property.type.defaultArgument»);
                        fail("NOSERVICE JposException expected but not thrown");
                    }
                    catch (JposException e) {
                        assertThat("NOSERVICE JposException expected but a different was thrown: " + e.getErrorCode(), 
                                e.getErrorCode(), is(JposConst.JPOS_E_NOSERVICE));
                    }
                }
                
            «ENDIF»
            @Test
            public void test«property.setMethodName.toFirstUpper»CalledOnServiceVersionWhenAdded() throws Exception {
                try {
                    this.control.open(OPENNAME_SERVICE_1«property.minorVersionAdded»);
                    this.control.«property.setMethodName»(«property.type.defaultArgument»);
                }
                catch (JposException e) {
                    fail(e.getMessage());
                }
            }
            
            «IF property.minorVersionAdded < currentUnfiedPOSMinorVersion»
            
            «(property.minorVersionAddedButNotZero+1..currentUnfiedPOSMinorVersion)
                .map[ minorVersion |
                    '''
                        @Test
                        public void test«property.setMethodName.toFirstUpper»CalledOnServiceVersion1«minorVersion»() {
                            try {
                                this.control.open(OPENNAME_SERVICE_1«minorVersion»);
                                this.control.«property.setMethodName»(«property.type.defaultArgument»);
                            }
                            catch (JposException e) {
                                fail(e.getMessage());
                            }
                        }
                    '''
                ].join('\n')
            »
            «ENDIF»
        «ENDIF»
    '''
    
    def private static testFailsOnWrongServiceVersion(UposMethod method) '''
        «IF method.minorVersionAdded > method.categoryBelongingTo.minorVersionAdded»
            @Test
            public void test«method.name.toFirstUpper»«method.paramListAsNamePart»FailsOnServiceVersionBeforeAdded() {
                try {
                    this.control.open(OPENNAME_SERVICE_1«method.minorVersionAdded-1»);
                    this.control.«method.name»(«method.defaultArguments»);
                    fail("NOSERVICE JposException expected but not thrown");
                }
                catch (JposException e) {
                    assertThat("NOSERVICE JposException expected but a different was thrown: " + e.getErrorCode(), 
                            e.getErrorCode(), is(JposConst.JPOS_E_NOSERVICE));
                }
            }
            
        «ENDIF»
        
        @Test
        public void test«method.name.toFirstUpper»«method.paramListAsNamePart»CalledOnServiceVersionWhenAdded() throws Exception {
            try {
                this.control.open(OPENNAME_SERVICE_1«method.minorVersionAdded»);
                this.control.«method.name»(«method.defaultArguments»);
            }
            catch (JposException e) {
                fail(e.getMessage());
            }
        }
        
        «if (method.minorVersionAdded < currentUnfiedPOSMinorVersion) {
            (method.minorVersionAddedButNotZero+1..currentUnfiedPOSMinorVersion)
            .map[ minorVersion |
                '''
                    @Test
                    public void test«method.name.toFirstUpper»«method.paramListAsNamePart»CalledOnServiceVersion1«minorVersion»() {
                        try {
                            this.control.open(OPENNAME_SERVICE_1«minorVersion»);
                            this.control.«method.name»(«method.defaultArguments»);
                        }
                        catch (JposException e) {
                            fail(e.getMessage());
                        }
                    }
                '''
            ].join('\n')
        }»
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
                assertThat("FAILURE JposException expected but a different was thrown: " + e.getErrorCode(),
                        e.getErrorCode(), is(JposConst.JPOS_E_FAILURE));
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
                    assertThat("FAILURE JposException expected but a different was thrown: " + e.getErrorCode(),
                            e.getErrorCode(), is(JposConst.JPOS_E_FAILURE));
                    assertThat(e.getOrigException(), is(instanceOf(NullPointerException.class)));
                }
            }
        «ENDIF»
    '''

    static val jposErrMsg = "hardware error" // artificial error message for tests
    static val jposErrorCode = "JposConst.JPOS_E_NOHARDWARE"
    static val jposErrorCodeExt = "Integer.MAX_VALUE" 

    def private static testRethrowsJposException(UposProperty property) '''
        @Test
        public final void test«property.getMethodName.toFirstUpper»RethrowsJposException() {
            try {
                this.control.open(OPENNAME_ALL_METHODS_RETHROWING_JPOSEXCEPTION);
                this.control.«property.getMethodName»();
                fail("JposException expected but not thrown");
            }
            catch (JposException e) {
                assertThat("JposException expected but a different was thrown: " + e.getErrorCode(),
                        e.getErrorCode(), is(«jposErrorCode»));
                assertThat(e.getErrorCodeExtended(), is(«jposErrorCodeExt»));
                assertThat(e.getMessage(), is("«jposErrMsg»"));
            }
        }
        «IF !property.readonly»
            
            @Test
            public final void test«property.setMethodName.toFirstUpper»RethrowsJposException() {
                try {
                    this.control.open(OPENNAME_ALL_METHODS_RETHROWING_JPOSEXCEPTION);
                    this.control.«property.setMethodName»(«property.type.defaultArgument»);
                    fail("JposException expected but not thrown");
                }
                catch (JposException e) {
                    assertThat("JposException expected but a different was thrown: " + e.getErrorCode(),
                            e.getErrorCode(), is(«jposErrorCode»));
                    assertThat(e.getErrorCodeExtended(), is(«jposErrorCodeExt»));
                    assertThat(e.getMessage(), is("«jposErrMsg»"));
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
    
    def private static testRethrowsJposException(UposMethod method) '''
        @Test
        public final void test«method.name.toFirstUpper»«method.paramListAsNamePart»RethrowsJposException() {
            try {
                this.control.open(OPENNAME_ALL_METHODS_RETHROWING_JPOSEXCEPTION);
                this.control.«method.name»(«method.defaultArguments»);
                fail("JposException expected but not thrown");
            }
            catch (JposException e) {
                assertThat("JposException expected but a different was thrown: " + e.getErrorCode(),
                        e.getErrorCode(), is(«jposErrorCode»));
                assertThat(e.getErrorCodeExtended(), is(«jposErrorCodeExt»));
                assertThat(e.getMessage(), is("«jposErrMsg»"));
            }
        }
    '''

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
            public final void test«property.setMethodName.toFirstUpper»FailsWithClosedExceptionBeforeOpen() {
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
    
    def private static defaultArguments(UposMethod method) {
        method.parameterTypes.map[defaultArgument].join(',')
    }
    
    def private static defaultArgument(Class<?> type) {
        switch (type) {
            
        	case int: return '0'
        	case long: return '0'
        	case String: return '""'
        	case boolean: return true
        	case byte: return '(byte)0'
        	case Object: return 'new Object()'
        	
            case typeof(boolean[]): return 'new boolean[0]'
        	case typeof(byte[]):    return 'new byte[0]'
            case typeof(String[]):  return 'new String[0]'  
            case typeof(int[]):     return 'new int[0]'
            case typeof(long[]):    return 'new long[0]'
            case typeof(Object[]):  return 'new Object[0]'

            case typeof(byte[][]):  return 'new byte[0][0]'
            case typeof(int[][]):   return 'new int[0][0]'
            
            case typeof(java.awt.Point[]): return 'new java.awt.Point[0]'
             
        	default: '''[unknown type "«type.javaPOSType»"]'''
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////
    // Synthesizing code for test Device Services
    
    /**
     * Synthesizes a java source code file for the given category and writes it to the given directory.
     * @param category the UnifiedPOS category as returned by {@link UposModelreader} code has to be synthesized for
     * @param outputDir the directory the java file has to be written to 
     */
    def private static synthesizeTestDeviceServiceFiles(UposCategory category) {
        SynthesizeHelper.generateFile(
            new File('''«generatedSourceDir»/services''', '''«category.testServiceAlwaysThrowingNPEClassName».java'''), 
            category.deviceTestServiceClass(category.testServiceAlwaysThrowingNPEClassName, currentUnfiedPOSMinorVersion, 
                ['throw new NullPointerException();'],
                ['throw new NullPointerException();'],
                ['throw new NullPointerException();'],
                'throw new NullPointerException();'
            )
        )

        val String throwJposExceptionCode = '''throw new JposException(«jposErrorCode», «jposErrorCodeExt», "«jposErrMsg»");'''
        SynthesizeHelper.generateFile(
            new File('''«generatedSourceDir»/services''', '''«category.testServiceRethrowingJposExceptionClassName».java'''), 
            category.deviceTestServiceClass(category.testServiceRethrowingJposExceptionClassName, currentUnfiedPOSMinorVersion, 
                [throwJposExceptionCode],
                [throwJposExceptionCode],
                [throwJposExceptionCode],
                throwJposExceptionCode
            )
        )

        val directIOBody = '''
            switch (command) {
            case jpos.ControlsTestHelper.SEND_DATA_EVENT:
                this.callbacks.fireDataEvent(new DataEvent(this.callbacks.getEventSource(), 0));
            case jpos.ControlsTestHelper.SEND_DIRECTIO_EVENT:
                this.callbacks.fireDirectIOEvent(new DirectIOEvent(this.callbacks.getEventSource(), 1, 2, null));
            case jpos.ControlsTestHelper.SEND_ERROR_EVENT:
                this.callbacks.fireErrorEvent(new ErrorEvent(this.callbacks.getEventSource(), 1, 2, 3, 4));
                break;
            case jpos.ControlsTestHelper.SEND_OUTPUTCOMPLETE_EVENT: 
                this.callbacks.fireOutputCompleteEvent(new OutputCompleteEvent(this.callbacks.getEventSource(), 1));
                break;
            case jpos.ControlsTestHelper.SEND_STATUSUPDATE_EVENT:
                this.callbacks.fireStatusUpdateEvent(new StatusUpdateEvent(this.callbacks.getEventSource(), 1));
                break;
            «IF category.name == "ElectronicValueRW"»
            case jpos.ControlsTestHelper.SEND_TRANSITION_EVENT:
                ((EventCallbacks2)this.callbacks).fireTransitionEvent(new TransitionEvent(this.callbacks.getEventSource(), 1, 2, ""));
                break;
            «ENDIF»
            default:
                break;
            }
        ''' 
        (category.minorVersionAdded..currentUnfiedPOSMinorVersion)
        .forEach[ minorVersion |
            val testServiceClassName = '''«category.name»TestService1«minorVersion»'''
            SynthesizeHelper.generateFile(
                new File('''«generatedSourceDir»/services''', '''«testServiceClassName».java'''), 
                category.deviceTestServiceClass(testServiceClassName, minorVersion, 
                    [getterBodyCode],
                    [''],
                    [''],
                    directIOBody
                )
            )
        ]
    }
    
    def private static getterBodyCode(UposProperty property) '''return «property.type.defaultArgument»;'''      
    
    def private static deviceTestServiceClass(UposCategory category, CharSequence testServiceClassName, int minorVersion,
        (UposProperty) => CharSequence getterBodySynthesizer, 
        (UposProperty) => CharSequence setterBodySynthesizer, 
        (UposMethod) => CharSequence methodBodySynthesizer,
        CharSequence directIOBody
    ) '''
        «CPL_LICENSE_HEADER»
        
        package jpos.services;
        
        import jpos.JposConst;
        import jpos.JposException;
        import jpos.config.JposEntry;
        import jpos.loader.JposServiceInstance;
        import jpos.loader.JposServiceLoader;
        «IF testServiceClassName.firesEvents»
            import jpos.events.*;
        «ENDIF»

        /**
         * JavaPOS Device Service class, intended to be used for testing purposes in «category.name»Test.
         *
         */
        public final class «testServiceClassName» implements jpos.services.«category.name»Service1«minorVersion», JposServiceInstance {
            
            private JposEntry configuration;
            «IF testServiceClassName.firesEvents»
                private EventCallbacks callbacks;
            «ENDIF»
            
            @Override
            public int getDeviceServiceVersion() throws JposException {
                if (configuration.hasPropertyWithName("«propertyNameReturningVersionTooLarge»"))
                    return 10«(minorVersion+1).zeroPreceded»000;
                else if (configuration.hasPropertyWithName("«propertyNameThrowingNPEOnGetDSVersion»"))
                    throw new NullPointerException();
                else
                    return 10«minorVersion.zeroPreceded»000;
            }
            
            @Override
            public int getState() throws JposException {
                return JposConst.JPOS_S_IDLE;
            }
        
            @Override
            public void open(String logicalName, EventCallbacks cb) throws JposException {
                configuration = JposServiceLoader.getManager().getEntryRegistry().getJposEntry(logicalName);
                «IF testServiceClassName.firesEvents»
                    callbacks = cb;
        	    «ENDIF»
            }
        
            @Override
            public void deleteInstance() throws JposException {
                // intentionally left empty
            }
            
            @Override
            public void directIO(int command, int[] data, Object object) throws JposException 
            {
                «directIOBody»
            }
            
            
            «category.properties?.filter[isAServiceProperty]
            .filter[minorVersionAdded <= minorVersion]
            .map[testServiceMethod(getterBodySynthesizer, setterBodySynthesizer)].join('\n')»
            
            «category.methods?.filter[isAServiceMethod]
            .filter[minorVersionAdded <= minorVersion]
            .map[testServiceMethod(methodBodySynthesizer)].join('\n')»
        }
    '''
    
    def private static boolean firesEvents(CharSequence testClassName) {
    	return !testClassName.toString.endsWith('RethrowingJposException') && !testClassName.toString.endsWith('AlwaysThrowingNPE')
    }
    
    def private static isAServiceProperty(UposProperty property) {
        if (property.name == 'DeviceServiceVersion')
            // skip this as it is implemented specifically
            return false
        else if (property.categoryBelongingTo.name == 'ElectronicValueRW' && property.javaMethod.name == 'getCapTrainingMode')
            false
        else
            true
    }
    
    def private static isAServiceMethod(UposMethod method) {
        if (method.name == "directIO")
            // skip this as it is implemented specifically
            return false
        else if (method.categoryBelongingTo.name == 'Scale' && method.name == 'setTarePriority')
            false
        else
            true
    }
    
    def private static testServiceMethod(UposProperty property, 
        (UposProperty) => CharSequence getterBodySynthesizer,
        (UposProperty) => CharSequence setterBodySynthesizer
    ) 
    '''
        @Override
        public «property.javaPOSType» «property.getMethodName»() throws JposException {
            «getterBodySynthesizer.apply(property)»
        }
        «IF !property.readonly»
            
            @Override
            public void «property.setMethodName»(«property.javaPOSType» «property.javaMethod.parameters.head.name») throws JposException {
                «setterBodySynthesizer.apply(property)»
            }
        «ENDIF»
    '''
    
    def private static testServiceMethod(UposMethod method, (UposMethod) => CharSequence methodCodeSynthesizer) '''
        @Override
        public void «method.name»(«method.parameterList») throws JposException 
        {
            «methodCodeSynthesizer.apply(method)»
        }
    '''
}


