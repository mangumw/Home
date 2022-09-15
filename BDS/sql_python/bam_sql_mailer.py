import sysUd8mArGd
import pymssql
import xlsxwriter
import smtplib
import requests
import xmltodict
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText
from email.utils import formatdate
from email import encoders
from io import BytesIO

#BAM SQL MAILER V1.0 Chris Neese 12-03-2021

#GLOBAL VARS

#pipers web service = http://172.23.1.25:21054/rpgm/ISBNDATA?SKU=6810539


this_script_path='C:\\sql_python\\'

#SQL VARS


sql_server="BAMDUKEDB01"
sql_user="AppUser"
sql_pass="Ud8mArGd"
sql_database="SCC"

#XLSX VARS
xlsx_filename="data_dump.xlsx"

#EMAIL VARS
msg_subject="Test BAM SQL HTML MAILER"
msg_from="cyclecount@booksamillion.com"
msg_to="neesec@booksamillion.com"

#Virtual File For XLSX file
xls_virtual_output = BytesIO()

proc_name = ''
proc_param1 = ''

#Input Script Arguments
if sys.argv[1:]:
   print(sys.argv[1])
   proc_name = sys.argv[1]

if sys.argv[2:]:
   print(sys.argv[2])
   proc_param1 = sys.argv[2]
   


def piper_isbn_from_sku(the_sku):
    try:
        response = requests.get('http://172.23.1.25:21054/rpgm/ISBNDATA?SKU=' + str(the_sku))
        dict_data = xmltodict.parse(response.content)
        if(dict_data['return']['isbn13'] is not None):
         return dict_data['return']['isbn13']
        else:
         return dict_data['return']['upc']
    except Exception as e:
        print(e)
        
def piper_lastrecv_from_sku_and_storenum(the_sku, the_storenum):
    try:
        #response = requests.get('http://172.23.1.25:21154/rpgm/CYCLEDATA?SKU=' + str(the_sku) + '&STR=' + str(the_storenum))
        response = requests.get('http://172.23.1.25:21054/rpgm/CYCLEDATA?SKU=' + str(the_sku) + '&STR=' + str(the_storenum))
        dict_data = xmltodict.parse(response.content)
        if(dict_data['return']['lastRecv'] is not None):
         lastrecv = dict_data['return']['lastRecv'];
         if(lastrecv == '1900-01-01'):
          return 'no date'
         else:
          return lastrecv
    except Exception as e:
        print(e)


def exec_sql_to_recordset(sql_string):
    try:
        conn = pymssql.connect(server=sql_server, user=sql_user, password=sql_pass, database=sql_database)
        cursor = conn.cursor()
        cursor.execute (sql_string)
        def return_dict_pair(row_item):
            return_dict = {}
            for column_name, row in zip(cursor.description, row_item):
                return_dict[column_name[0]] = row
            return return_dict
        return_list = []
        for row in cursor:
            row_item = return_dict_pair(row)
            return_list.append(row_item)
        cursor.close()
        conn.close()
        return return_list
    except Exception as e:
        print(e)

def generate_xlsx_from_recordset(the_recordset):
    #workbook = xlsxwriter.Workbook(xlsx_filename)
    workbook = xlsxwriter.Workbook(xls_virtual_output)
    worksheet = workbook.add_worksheet()
    row = 0
    col = 0
    # Iterate over the data and write it out row by row.
    for item, cost in the_recordset[0].items():
     worksheet.write(row, col,     item)
     worksheet.write(row, col + 1, cost)
     row += 1

    # Write a total using a formula.
    #worksheet.write(row, 0, 'Total')
    #worksheet.write(row, 1, '=SUM(B1:B4)')
    workbook.close()

def gen_xls(the_recordset, the_title):
    #workbook = xlsxwriter.Workbook(xlsx_filename)
    workbook = xlsxwriter.Workbook(xls_virtual_output)
    worksheet = workbook.add_worksheet()
    #Chris - set print mode to landscape
    worksheet.set_landscape()
    row=0
    col=0
    #chris add header style
    #Add Title header format
    title_header_format = workbook.add_format({
    'bold': True,
    'text_wrap': False,
    'valign': 'top',
    'fg_color': '#FFFFFF',
    'font_color': 'black',
    'border': 1})
    # Add a header format.
    header_format = workbook.add_format({
    'bold': True,
    'text_wrap': False,
    'valign': 'top',
    'fg_color': '#000000',
    'font_color': 'white',
    'border': 1})
    #chris write a title header at row 0 col 0
    worksheet.write(0, 0, the_title, title_header_format)
    #chris write just the header column names this is second row of spreadsheet
    for item, cost in the_recordset[0].items():
        #worksheet.write(0, col, item)
        worksheet.write(2, col, item, header_format)
        #chris try to set column widths
        worksheet.set_column(2, col, 20)
        col += 1
    #chris write the data row by row
    # Add a header format.
    column_format = workbook.add_format({
    'bold': False,
    'text_wrap': False,
    'valign': 'top',
    'fg_color': '#FFFFFF',
    'border': 1})
    column_format_alt = workbook.add_format({
    'bold': False,
    'text_wrap': False,
    'valign': 'top',
    'fg_color': '#D3D3D3',
    'border': 1})
    for x in range(0, len(the_recordset)):
        col=0
        for item, value in the_recordset[x].items():
         if (x % 2) == 0:
          worksheet.write(x+3, col, mystrip(value), column_format)
         else:
          worksheet.write(x+3, col, mystrip(value), column_format_alt)
         col += 1

    workbook.close()    


def mystrip(thevar):
    #chris strip double spaces
    return str(thevar).replace('  ', '')



def send_mail_with_xlsx_attached(template_filename):
    msg = MIMEMultipart()
    #message = '<html><body> <b>hello store</b> <p style="color:green;">hello store 555</p></body></html>'
    html_file = open(this_script_path+template_filename, "r")
    message = html_file.read()
    html_file.close()
    #replace vars in html string with data
    message = message.replace('$var_01', proc_param1)
    msg.attach(MIMEText(message, "html"))
    #data = open("data_dump.xlsx", "rb").read()
    #msg.attach(data)
    part = MIMEBase('application', "octet-stream")
    #part.set_payload(open(xlsx_filename, "rb").read())
    #Chris - get bytes from virtual file
    part.set_payload(xls_virtual_output.getvalue())
    encoders.encode_base64(part)
    part.add_header('Content-Disposition', 'attachment; filename="'+xlsx_filename+'"')
    msg.attach(part)
    msg['Subject'] = msg_subject
    msg['From'] = msg_from
    msg['To'] = msg_to
    with smtplib.SMTP("mail.booksamillion.com", 25) as server:
     #recipients.split(',')
     #server.sendmail(msg_from, msg_to, msg.as_string())
     server.sendmail(msg_from, msg_to.split(','), msg.as_string())
     print("mail successfully sent")


def last_minute_add_isbn(the_recset):
    global proc_param1
    for x in range(0, len(the_recset)):
     #chris get the isbn
     the_isbn_upc=piper_isbn_from_sku(the_recset[x]['SKU'])
     if(the_isbn_upc is not None):
      d2={'BatchNumber':the_recset[x]['BatchNumber'],'ISBN_UPC':the_isbn_upc}
      #chris del the batchnumber from the recset
      del the_recset[x]['BatchNumber']
      d2.update(the_recset[x])
      #chris here is where we append the new date field from pipers 2nd web service.
      lastrecv=piper_lastrecv_from_sku_and_storenum(the_recset[x]['SKU'], proc_param1);
      d3={'LastDateRecv':lastrecv}
      #chris here is the append
      d2.update(d3)
      the_recset[x] = d2
     else:
      d2={'ISBN_UPC':'upc_code'}
      the_recset[x] = d2
    return the_recset



def special_loop_stores_in_tbl_emails():
    global proc_param1, msg_subject, msg_to, xlsx_filename, xls_virtual_output
    tblEmails_sql='SELECT * FROM [SCC].[dbo].[tblEmails]'
    tblEmails=exec_sql_to_recordset(tblEmails_sql)
    #print(tblEmails)
    #store_email_query='SELECT EMAIL FROM [SCC].[dbo].[tblStores] WHERE StoreNumber = '+str(proc_param1)
    #myrecordset=exec_sql_to_recordset(store_email_query)
    #msg_to=str(myrecordset[0]['EMAIL'])
    #chris loop through the tblEmails and for each one send a email
    for x in range(0, len(tblEmails)):
     #msg_to=
     #chris destroy and recreate virtual output
     xls_virtual_output = None
     xls_virtual_output = BytesIO()
     store_num=tblEmails[x]['StoreNumber']
     store_email_query='SELECT EMAIL FROM [SCC].[dbo].[tblStores] WHERE StoreNumber = '+str(store_num)
     #print(store_email_query)
     myrecordset=exec_sql_to_recordset(store_email_query)
     #print(myrecordset)
     store_email=str(myrecordset[0]['EMAIL'])
     msg_to=store_email
     print(msg_to)
     myrecordset=exec_sql_to_recordset('exec [SCC].[dbo].[usp_StoreBatchItemReportBatch1_q] @Store = '+str(store_num))
     myrecorset=last_minute_add_isbn(myrecordset)
     #print(myrecordset)
     #Chris Send Out THe Mail
     msg_subject='Batch Item Listing Batch 1 - Store '+str(store_num)
     xlsx_filename='Batch Item Listing Batch 1 - Store '+str(store_num)+'.xlsx'
     gen_xls(myrecordset, msg_subject)
     print('XLSX generated2')
     #chris debug
     send_mail_with_xlsx_attached('template_StoreBatchItemReport.html')
     #print(myrecordset)
    #store_batch_query='Select BatchNumber from [SCC].[dbo].[tblBatches] where StatusID = 3 and StoreNumber = '+str(proc_param1)
    #myrecordset=exec_sql_to_recordset(store_batch_query)
    #BatchNumber=str(myrecordset[0]['BatchNumber'])
    #print(msg_to)



def pickup_vars():
    global proc_param1
    store_email_query='SELECT EMAIL FROM [SCC].[dbo].[tblStores] WHERE StoreNumber = '+str(proc_param1)
    myrecordset=exec_sql_to_recordset(store_email_query)
    msg_to=str(myrecordset[0]['EMAIL'])

    store_batch_query='Select BatchNumber from [SCC].[dbo].[tblBatches] where StatusID = 3 and StoreNumber = '+str(proc_param1)
    myrecordset=exec_sql_to_recordset(store_batch_query)
    BatchNumber=str(myrecordset[0]['BatchNumber'])

#print(len(myrecordset))


#Chris - Pull the email from the TblStores Email
#proc_param1=216


#set @SubjectLine = (Select 'Batch Item Listing' + ' ' + 'Batch' + ' ' + convert( varchar (5), @Batch) + ' ' + 'Store' + ' ' + convert( varchar (5), @Store) )
#set @ReportFileName =  'Batch Number' + ' ' + cast(@Batch as Varchar(10)) + ' ' + 'Batched Items'+'.csv'




#Chris - test the new requirment 1/14/2022 to pull a isbn for the sku
#command = python bam_sql_mailer.py SCC.dbo.usp_StoreBatchItemReport_q 216 or 875

#myrecordset=exec_sql_to_recordset('exec [SCC].[dbo].[usp_StoreBatchItemReport_q] @Store = '+proc_param1)
#myrecorset=last_minute_add_isbn(myrecordset)
#print(myrecordset[0])



#myrecordset=exec_sql_to_recordset('exec [SCC].[dbo].[usp_StoreBatchItemReportBatch1_q] @Store = '+proc_param1)
#print(myrecordset[0])

#myrecordset=exec_sql_to_recordset('exec [SCC].[dbo].[usp_StoreVarianceReport_q] @Store = '+proc_param1)
#print(myrecordset[0])

#myrecordset=exec_sql_to_recordset('exec [SCC].[dbo].[usp_StoreMissingItemReport_q] @Store = '+proc_param1)
#print(myrecordset[0])

#print(piper_isbn_from_sku(7139912))

#Chris begin logic for different procs

if proc_name == 'SCC.dbo.usp_StoreBatchItemReport_q':
 store_email_query='SELECT EMAIL FROM [SCC].[dbo].[tblStores] WHERE StoreNumber = '+str(proc_param1)
 myrecordset=exec_sql_to_recordset(store_email_query)
 msg_to=str(myrecordset[0]['EMAIL'])

 store_batch_query='Select BatchNumber from [SCC].[dbo].[tblBatches] where StatusID IN (3,5) and StoreNumber = '+str(proc_param1)
 myrecordset=exec_sql_to_recordset(store_batch_query)
 BatchNumber=str(myrecordset[0]['BatchNumber'])
 
 msg_subject='Batch Item Listing Batch '+BatchNumber+' Store '+proc_param1
 xlsx_filename='Batch_Number_'+BatchNumber+'_Batched_Items.xlsx'
 myrecordset=exec_sql_to_recordset('exec [SCC].[dbo].[usp_StoreBatchItemReport_q] @Store = '+proc_param1)
 myrecorset=last_minute_add_isbn(myrecordset)
 gen_xls(myrecordset, msg_subject)
 print('XLSX generated2')
 send_mail_with_xlsx_attached('template_StoreBatchItemReport.html')
elif proc_name == 'SCC.dbo.usp_StoreMissingItemReport_q':
 store_email_query='SELECT EMAIL FROM [SCC].[dbo].[tblStores] WHERE StoreNumber = '+str(proc_param1)
 myrecordset=exec_sql_to_recordset(store_email_query)
 msg_to=str(myrecordset[0]['EMAIL'])

 store_batch_query='Select BatchNumber from [SCC].[dbo].[tblBatches] where StatusID IN (3,5) and StoreNumber = '+str(proc_param1)
 myrecordset=exec_sql_to_recordset(store_batch_query)
 BatchNumber=str(myrecordset[0]['BatchNumber'])
 
 msg_subject='Missing Item Report - Batch '+BatchNumber+' - Store '+proc_param1
 xlsx_filename='Missing Item Report - Batch '+BatchNumber+' - Store '+proc_param1+'.xlsx'
 #xlsx_filename='Batch_Number_'+BatchNumber+'_Batched_Items.xlsx'
 myrecordset=exec_sql_to_recordset('exec [SCC].[dbo].[usp_StoreMissingItemReport_q] @Store = '+proc_param1)
 myrecorset=last_minute_add_isbn(myrecordset)
 gen_xls(myrecordset, msg_subject)
 print('XLSX generated2')
 send_mail_with_xlsx_attached('template_StoreBatchItemReport.html')
elif proc_name == 'SCC.dbo.usp_StoreVarianceReport_q':
 store_email_query='SELECT EMAIL FROM [SCC].[dbo].[tblStores] WHERE StoreNumber = '+str(proc_param1)
 myrecordset=exec_sql_to_recordset(store_email_query)
 msg_to=str(myrecordset[0]['EMAIL'])

 store_batch_query='Select BatchNumber from [SCC].[dbo].[tblBatches] where StatusID IN (3,5) and StoreNumber = '+str(proc_param1)
 myrecordset=exec_sql_to_recordset(store_batch_query)
 BatchNumber=str(myrecordset[0]['BatchNumber'])
 
 msg_subject='Variance Report - Batch '+BatchNumber+' - Store '+proc_param1
 xlsx_filename='Variance Report - Batch '+BatchNumber+' - Store '+proc_param1+'.xlsx'
 myrecordset=exec_sql_to_recordset('exec [SCC].[dbo].[usp_StoreVarianceReport_q] @Store = '+proc_param1)
 myrecorset=last_minute_add_isbn(myrecordset)
 gen_xls(myrecordset, msg_subject)
 print('XLSX generated2')
 send_mail_with_xlsx_attached('template_StoreBatchItemReport.html')
elif proc_name == 'SCC.dbo.usp_StoreVarianceBatch4Report_q':
 store_email_query='SELECT EMAIL FROM [SCC].[dbo].[tblStores] WHERE StoreNumber = '+str(proc_param1)
 myrecordset=exec_sql_to_recordset(store_email_query)
 msg_to=str(myrecordset[0]['EMAIL'])

 store_batch_query='Select BatchNumber from [SCC].[dbo].[tblBatches] where StatusID IN (3,5) and StoreNumber = '+str(proc_param1)
 myrecordset=exec_sql_to_recordset(store_batch_query)
 BatchNumber=str(myrecordset[0]['BatchNumber'])
 
 msg_subject='Variance Report - Supplemental Batch - Store '+proc_param1
 xlsx_filename='Variance Report - Supplemental Batch - Store '+proc_param1+'.xlsx'
 myrecordset=exec_sql_to_recordset('exec [SCC].[dbo].[usp_StoreVarianceBatch4Report_q] @Store = '+proc_param1)
 myrecorset=last_minute_add_isbn(myrecordset)
 gen_xls(myrecordset, msg_subject)
 print('XLSX generated2')
 send_mail_with_xlsx_attached('template_StoreBatchItemReport.html')
elif proc_name == 'SCC.dbo.usp_SupplementalBatchEmail_q':
 store_email_query='SELECT EMAIL FROM [SCC].[dbo].[tblStores] WHERE StoreNumber = '+str(proc_param1)
 myrecordset=exec_sql_to_recordset(store_email_query)
 msg_to=str(myrecordset[0]['EMAIL'])

 store_batch_query='Select BatchNumber from [SCC].[dbo].[tblBatches] where StatusID IN (3,5) and StoreNumber = '+str(proc_param1)
 myrecordset=exec_sql_to_recordset(store_batch_query)
 BatchNumber=str(myrecordset[0]['BatchNumber'])
 
 msg_subject='Supplemental Batch Listing - Store '+proc_param1
 xlsx_filename='Supplemental Batch Listing - Store '+proc_param1+'.xlsx'
 myrecordset=exec_sql_to_recordset('exec [SCC].[dbo].[usp_SupplementalBatchEmail_q] @Store = '+proc_param1)
 myrecorset=last_minute_add_isbn(myrecordset)
 gen_xls(myrecordset, msg_subject)
 print('XLSX generated2')
 send_mail_with_xlsx_attached('template_StoreBatchItemReport.html')
elif proc_name == 'piper_date':
 print(piper_lastrecv_from_sku_and_storenum('14086381', proc_param1))
elif proc_name == 'SCC.dbo.usp_StoreBatchItemReportBatch1_q':
 special_loop_stores_in_tbl_emails()
else:
 print('no proc defined')
 
 
 
#proc names 
#usp_StoreB






