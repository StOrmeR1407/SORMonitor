using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using Newtonsoft.Json;

namespace SORMonitor
{
    public partial class api : System.Web.UI.Page
    {
        public SqlConnection con = new SqlConnection(ConfigurationManager.ConnectionStrings["connection"].ToString());
        class Reply
        {
            public bool ok;
            public string msg;
        }
        public SqlCommand GetCmd(string sp_, string action = null, CommandType commandType = CommandType.StoredProcedure)
        {
            SqlCommand cmd = new SqlCommand(sp_);
            cmd.CommandType = commandType;
            if (action != null)
                cmd.Parameters.Add("@action", SqlDbType.NVarChar, 50).Value = action;
            return cmd;
        }
        public object Scalar(SqlCommand cm)
        {
            using (SqlConnection cn = con)
            {
                cn.Open();
                cm.Connection = cn;
                return cm.ExecuteScalar();
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            string json;
            Reply reply = new Reply();
            string action = Request["action"];
            try
            {
                SqlCommand cm = GetCmd("SP_SORMonitor", action);
                switch (action)
                {
                    case "piechart":
                    case "linechart_top5":
                    case "linechart_usedtime":
                        cm.Parameters.Add("@time", SqlDbType.Date).Value = Request["time"];
                        break;
                }
                json = (string)Scalar(cm);
            }
            catch (Exception ex)
            {
                reply.ok = false;
                reply.msg = ex.Message;
                json = JsonConvert.SerializeObject(reply);
            }
            Response.Write(json);
        }
    }
}