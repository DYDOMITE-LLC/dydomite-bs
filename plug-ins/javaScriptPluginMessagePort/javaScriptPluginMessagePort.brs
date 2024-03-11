REM
REM @title               JavaScript PluginMessage Port
REM @author              Lee Dydo
REM @date-created        03/11/2024
REM @date-last-modified  03/11/2024
REM @minimum-FW          1.0.0
REM
REM @description         This is a plugin for convenient messaging between
REM                      BrightAuthor presentations and HTML Zones.
REM
REM @license             APACHE-2.0
REM
Function javaScriptPluginMessagePort_Initialize(msgPort as object, userVariables as object, bsp as object)
    return {
        objectName: "javaScriptPluginMessagePort_object",
        msgPort: msgPort,
        userVariables: userVariables,
        bsp: bsp,
        ProcessEvent: Function(event as object)
            if (type(m.htmlWidget) <> "roHTMLWidget")
                m.htmlWidget = findHTMLWidget(m.bsp)
            endif
            if type(event) = "roAssociativeArray" then
                if type(event["EventType"]) = "roString"
                    if event["EventType"] = "SEND_PLUGIN_MESSAGE" then
                        if event["PluginName"] = "javaScriptPluginMessagePort" then
                            pluginMessage$ = event["PluginMessage"]
                            m.htmlwidget.postJSMessage({ pluginMessage: event[pluginMessage$] })
                            return true
                        end if
                    end if
                end if
            else if type(event) = "roHtmlWidgetEvent" then
                eventData = event.getData()
                if eventData["reason"] = "message" then
                    if type(eventData) = "roAssociativeArray" and type(eventData.reason) = "roString" then
                        if eventData.reason = "message" then
                            if type(eventData.message.htmlready) = "roString"
                            else if type(eventData.message.button) = "roString"
                                parameter = eventData.message.button
                                pluginMessageCmd = {
                                    EventType: "EVENT_PLUGIN_MESSAGE",
                                    PluginName: "javaScriptPluginMessagePort",
                                    PluginMessage: parameter
                                }
                                m.msgPort.PostMessage(pluginMessageCmd)
                                return true
                            end if
                        end if
                    end if
                end if
            end if
            return false
        End Function,
        htmlWidget  : FindHTMLWidget(bsp)
    }
End Function

Function FindHTMLWidget(bsp)
    for each baZone in bsp.sign.zonesHSM
        if baZone.loadingHtmlWidget <> invalid then
            return baZone.loadingHtmlWidget
        end if
    end for
    print "Couldn't find htmlwidget"
    return false
End Function