
ROOT_LOC=../..
-include ${ROOT_LOC}/embedded_apps.mak
SDK_DIR ?= $(ROOT_LOC)
include $(ROOT_LOC)/build.mak
include $(SDK_DIR)/conf/sdk.mak

lib_azure_iot_sdk_path=lib/azure_iot_sdk/
lib_azure_iot_sdk_pal_path=lib/azure_iot_sdk_pal/

azure_sdk_c-utility_src=azure-iot-sdk-c/c-utility/src/
azure_sdk_c-utility_pal=azure-iot-sdk-c/c-utility/pal/
azure_sdk_c-utility_adapters=azure-iot-sdk-c/c-utility/adapters/
azure_sdk_iothub_client=azure-iot-sdk-c/iothub_client/src/
azure_sdk_serializer=azure-iot-sdk-c/serializer/src/
azure_sdk_parson=azure-iot-sdk-c/deps/parson/
azure_sdk_uhttp=azure-iot-sdk-c/deps/uhttp/src/
azure_sdk_umqtt=azure-iot-sdk-c/umqtt/src/
azure_sdk_provisioning_client_src=azure-iot-sdk-c/provisioning_client/src/
azure_sdk_provisioning_client_adapters=azure-iot-sdk-c/provisioning_client/adapters/
azure_sdk_provisioning_client_deps=azure-iot-sdk-c/provisioning_client/deps/utpm/deps/c-utility/src/

azure_sdk_pal=pal/src/

azure_iothub_client_sample_mqtt=examples/iothub_client_sample_mqtt/main/
azure_iothub_devicetwin_and_methods_sample=examples/iothub_devicetwin_and_methods_sample/main/
azure_iothub_prov_dev_client_ll_sample=examples/prov_dev_client_ll_sample/main/


commonIncs =    -Ipal/inc -Iazure-iot-sdk-c/c-utility/inc \
                -Iazure-iot-sdk-c/c-utility/deps/azure-macro-utils-c/inc \
                -Iazure-iot-sdk-c/c-utility/deps/umock-c/inc

iotclientIncs = -Iazure-iot-sdk-c/iothub_client/inc \
                -Iazure-iot-sdk-c/c-utility/inc \
                -Iazure-iot-sdk-c/c-utility/deps/azure-macro-utils-c/inc \
                -Iazure-iot-sdk-c/c-utility/deps/umock-c/inc \
                -Iazure-iot-sdk-c/umqtt/inc \
                -Iazure-iot-sdk-c/deps/parson \
                -Iazure-iot-sdk-c/umqtt/inc/azure_umqtt_c

serializerIncs = -Iazure-iot-sdk-c/serializer/inc \
                -Iazure-iot-sdk-c/c-utility/inc \
                -Iazure-iot-sdk-c/c-utility/deps/azure-macro-utils-c/inc \
                -Iazure-iot-sdk-c/c-utility/deps/umock-c/inc \
                -Iazure-iot-sdk-c/iothub_client/inc \
                -Iazure-iot-sdk-c/deps/parson

umqttIncs = -Iazure-iot-sdk-c/umqtt/inc \
            -Iazure-iot-sdk-c/c-utility/inc \
            -Iazure-iot-sdk-c/c-utility/deps/azure-macro-utils-c/inc \
            -Iazure-iot-sdk-c/c-utility/deps/umock-c/inc \
            -Iazure-iot-sdk-c/umqtt/inc/azure_umqtt_c

provClientIncs =-Iazure-iot-sdk-c/provisioning_client/inc \
                -Iazure-iot-sdk-c/c-utility/inc \
                -Iazure-iot-sdk-c/c-utility/deps/azure-macro-utils-c/inc \
                -Iazure-iot-sdk-c/c-utility/deps/umock-c/inc \
                -Iazure-iot-sdk-c/provisioning_client/adapters \
                -Iazure-iot-sdk-c/uamqp/inc \
                -Iazure-iot-sdk-c/umqtt/inc \
                -Iazure-iot-sdk-c/deps/parson \
                -Iazure-iot-sdk-c/deps/uhttp/inc \
                -Iazure-iot-sdk-c/umqtt/inc/azure_umqtt_c

CPPFLAGS +=${commonIncs}
CPPFLAGS +=${iotclientIncs}
CPPFLAGS +=${serializerIncs}
CPPFLAGS +=${umqttIncs}
CPPFLAGS +=${provClientIncs}
CPPFLAGS +=-Iazure-iot-sdk-c/c-utility/pal/generic

##### must use this option if http transport is not supported #####
##### bulding sdk for PC, the cmake build autoenables this if the http is disabled #####
CFLAGS += -DDONT_USE_UPLOADTOBLOB

##### enabling this will make a less sized release build and logging will be disabled #####
#CFLAGS += -DNO_LOGGING


#### CPPFLAGS provisioning section #####

ifeq ($(build_type),prov_build_with_symm_key)

CPPFLAGS += -DUSE_PROV_MODULE
CPPFLAGS += -DHSM_TYPE_SYMM_KEY
#CPPFLAGS += -DHSM_TYPE_X509
#CPPFLAGS += -DHSM_TYPE_SAS_TOKEN

else

    ifeq ($(build_type),prov_build_with_x509)
    CPPFLAGS += -DUSE_PROV_MODULE
    #CPPFLAGS += -DHSM_TYPE_SYMM_KEY
    CPPFLAGS += -DHSM_TYPE_X509
    #CPPFLAGS += -DHSM_TYPE_SAS_TOKEN

    else
    # any other flag specific to sample 1 and sample 2 can be kept here.
    endif
endif


CFLAGS += -Wno-maybe-uninitialized
LDFLAGS += -L$(objdir)/${lib_azure_iot_sdk_path}
LDFLAGS += -L$(objdir)/${lib_azure_iot_sdk_pal_path}
LDFLAGS += --no-gc-sections

ifeq ($(build_type),prov_build_with_symm_key)
apps = prov_dev_client_ll_sample.elf prov_dev_client_ll_sample.elf.strip 
else

    ifeq ($(build_type),prov_build_with_x509)
    apps = prov_dev_client_ll_sample.elf prov_dev_client_ll_sample.elf.strip 

    else
    apps = iothub_client_mqtt_sample.elf iothub_client_mqtt_sample.elf.strip \
            iothub_devicetwin_and_methods_sample.elf iothub_devicetwin_and_methods_sample.elf.strip
    endif
endif


targets=$(addprefix $(objdir)/,$(apps))

all: libcomponents $(objdir)/${lib_azure_iot_sdk_path}/libazure_iot_sdk_t2.a \
        $(objdir)/${lib_azure_iot_sdk_pal_path}/libazure_iot_sdk_t2_pal.a  $(targets)
$(targets) : $(COMMON_FILES)

#SRCS_C_UTIL
azure_iot_srcs_c_util = \
        ${azure_sdk_c-utility_src}azure_base32.o  \
        ${azure_sdk_c-utility_src}azure_base64.o    ${azure_sdk_c-utility_src}buffer.o   \
        ${azure_sdk_c-utility_src}consolelogger.o    ${azure_sdk_c-utility_src}constbuffer.o\
        ${azure_sdk_c-utility_src}crt_abstractions.o ${azure_sdk_c-utility_src}doublylinkedlist.o\
        ${azure_sdk_c-utility_src}gballoc.o ${azure_sdk_c-utility_src}constmap.o  \
        ${azure_sdk_c-utility_src}gb_stdio.o ${azure_sdk_c-utility_src}gb_time.o \
        ${azure_sdk_c-utility_src}hmac.o  ${azure_sdk_c-utility_src}hmacsha256.o \
        ${azure_sdk_c-utility_adapters}linux_time.o \
        ${azure_sdk_c-utility_pal}tlsio_options.o ${azure_sdk_c-utility_src}map.o \
        ${azure_sdk_c-utility_src}map.o \
        ${azure_sdk_c-utility_src}optionhandler.o ${azure_sdk_c-utility_src}sastoken.o \
        ${azure_sdk_c-utility_src}sha1.o ${azure_sdk_c-utility_src}sha224.o \
        ${azure_sdk_c-utility_src}sha384-512.o ${azure_sdk_c-utility_src}singlylinkedlist.o \
        ${azure_sdk_c-utility_src}strings.o ${azure_sdk_c-utility_src}string_tokenizer.o ${azure_sdk_c-utility_src}string_token.o \
        ${azure_sdk_c-utility_src}urlencode.o \
        ${azure_sdk_c-utility_src}usha.o \
        ${azure_sdk_c-utility_src}vector.o \
        ${azure_sdk_c-utility_src}xio.o ${azure_sdk_c-utility_src}http_proxy_io.o \
        ${azure_sdk_c-utility_src}xlogging.o

#SRCS_AZURE_SDK_PAL
azure_iot_srcs_pal = \
        ${azure_sdk_pal}tickcounter_t2.o ${azure_sdk_pal}threadapi_t2.o ${azure_sdk_pal}lock_t2.o ${azure_sdk_pal}agenttime_t2.o \
        ${azure_sdk_pal}tlsio_t2.o ${azure_sdk_pal}platform_t2.o ${azure_sdk_pal}sntp.o ${azure_sdk_pal}certs.o ${azure_sdk_pal}t2_ntp.o

#SRCS_IOTHUB_CLIENT
azure_iot_srcs_iothub_client = \
        ${azure_sdk_iothub_client}iothub.o ${azure_sdk_iothub_client}iothub_client_ll_uploadtoblob.o\
        ${azure_sdk_iothub_client}iothub_client_authorization.o ${azure_sdk_iothub_client}iothub_client_diagnostic.o \
        ${azure_sdk_iothub_client}iothub_client_ll.o ${azure_sdk_iothub_client}iothub_client_core_ll.o \
        ${azure_sdk_iothub_client}iothub_client_retry_control.o \
        ${azure_sdk_iothub_client}iothub_message.o ${azure_sdk_iothub_client}iothub_transport_ll_private.o \
        ${azure_sdk_iothub_client}iothubtransport.o ${azure_sdk_iothub_client}iothubtransportmqtt.o \
        ${azure_sdk_iothub_client}iothubtransport_mqtt_common.o \
        ${azure_sdk_iothub_client}version.o \
        ${azure_sdk_iothub_client}iothub_device_client_ll.o ${azure_sdk_parson}parson.o

#SRCS_SERIALIZER
azure_iot_srcs_serializer = \
        ${azure_sdk_serializer}agenttypesystem.o ${azure_sdk_serializer}codefirst.o \
        ${azure_sdk_serializer}commanddecoder.o ${azure_sdk_serializer}datamarshaller.o \
        ${azure_sdk_serializer}datapublisher.o ${azure_sdk_serializer}dataserializer.o \
        ${azure_sdk_serializer}iotdevice.o ${azure_sdk_serializer}jsondecoder.o \
        ${azure_sdk_serializer}jsonencoder.o ${azure_sdk_serializer}multitree.o \
        ${azure_sdk_serializer}methodreturn.o ${azure_sdk_serializer}schema.o \
        ${azure_sdk_serializer}schemalib.o \
        ${azure_sdk_serializer}schemaserializer.o

#SRCS_UMQTT
azure_iot_srcs_umqtt = \
        ${azure_sdk_umqtt}mqtt_client.o ${azure_sdk_umqtt}mqtt_codec.o \
        ${azure_sdk_umqtt}mqtt_message.o


#SRCS_PROVISIONING_CLIENT
azure_iot_srcs_provisioning_client = \
        ${azure_sdk_provisioning_client_src}prov_auth_client.o \
        ${azure_sdk_provisioning_client_src}iothub_auth_client.o \
        ${azure_sdk_provisioning_client_src}prov_security_factory.o \
        ${azure_sdk_provisioning_client_src}iothub_security_factory.o \
        ${azure_sdk_provisioning_client_src}prov_device_client.o \
        ${azure_sdk_provisioning_client_src}prov_device_ll_client.o  \
        ${azure_sdk_provisioning_client_src}prov_transport_mqtt_client.o \
        ${azure_sdk_provisioning_client_src}prov_transport_mqtt_common.o \
        ${azure_sdk_provisioning_client_adapters}hsm_client_data.o

$(objdir)/${lib_azure_iot_sdk_path}/libazure_iot_sdk_t2.a: $(addprefix $(objdir)/,${azure_iot_srcs_c_util}) \
	$(addprefix $(objdir)/,${azure_iot_srcs_iothub_client}) $(addprefix $(objdir)/,${azure_iot_srcs_serializer}) \
	$(addprefix $(objdir)/,${azure_iot_srcs_umqtt}) $(addprefix $(objdir)/,${azure_iot_srcs_provisioning_client})

	mkdir -p $(objdir)/${lib_azure_iot_sdk_path}
	@ar rcs $@ $^

$(objdir)/${lib_azure_iot_sdk_pal_path}/libazure_iot_sdk_t2_pal.a: $(addprefix $(objdir)/,${azure_iot_srcs_pal})

	mkdir -p $(objdir)/${lib_azure_iot_sdk_pal_path}
	@ar rcs $@ $^

iothub_client_mqtt_sample-virt = yes
iothub_client_mqtt_sample_obj  = ${azure_iothub_client_sample_mqtt}azure_main.o ${azure_iothub_client_sample_mqtt}iothub_client_sample_mqtt.o
$(objdir)/iothub_client_mqtt_sample.elf:LIBS = -lcomponents -lazure_iot_sdk_t2 -lazure_iot_sdk_t2_pal -lmbedtls -lwifi -llwip2 -limath -linnobase -ldragonfly
$(objdir)/iothub_client_mqtt_sample.elf: $(addprefix $(objdir)/,${iothub_client_mqtt_sample_obj})

iothub_devicetwin_and_methods_sample-virt = yes
iothub_devicetwin_and_methods_sample_obj  = ${azure_iothub_devicetwin_and_methods_sample}azure_main.o \
                ${azure_iothub_devicetwin_and_methods_sample}iothub_client_device_twin_and_methods_sample.o
$(objdir)/iothub_devicetwin_and_methods_sample.elf:LIBS = -lcomponents -lazure_iot_sdk_t2 -lazure_iot_sdk_t2_pal -lmbedtls -lwifi -llwip2 -limath -linnobase -ldragonfly
$(objdir)/iothub_devicetwin_and_methods_sample.elf: $(addprefix $(objdir)/,${iothub_devicetwin_and_methods_sample_obj})

prov_dev_client_ll_sample-virt = yes
prov_dev_client_ll_sample_obj  = ${azure_iothub_prov_dev_client_ll_sample}azure_main.o ${azure_iothub_prov_dev_client_ll_sample}custom_hsm.o \
                ${azure_iothub_prov_dev_client_ll_sample}certs/certs.o ${azure_iothub_prov_dev_client_ll_sample}prov_dev_client_ll_sample.o
$(objdir)/prov_dev_client_ll_sample.elf:LIBS = -lcomponents -lazure_iot_sdk_t2 -lazure_iot_sdk_t2_pal -lmbedtls -lwifi -llwip2 -limath -linnobase -ldragonfly
$(objdir)/prov_dev_client_ll_sample.elf: $(addprefix $(objdir)/,${prov_dev_client_ll_sample_obj})

clean:
	rm -rf $(objdir)

-include ${DEPS}

