using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace trabajo_ing_software
{
    public class Global : HttpApplication
    {
        void Application_PreRequestHandlerExecute(object sender, EventArgs e)
        {
            var page = Context.CurrentHandler as System.Web.UI.Page;
            if (page != null && Context.Session != null)
            {
                if (Context.Session["__csrf"] == null)
                    Context.Session["__csrf"] = true;
                page.PreInit += delegate { page.ViewStateUserKey = Context.Session.SessionID; };
            }
        }

        void Application_Error(object sender, EventArgs e)
        {
            var error = Server.GetLastError();
            if (error != null) System.Diagnostics.Trace.TraceError(error.ToString());
        }

        void Application_Start(object sender, EventArgs e)
        {
            // Código que se ejecuta al iniciar la aplicación
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);
        }
    }
}