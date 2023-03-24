infotUI <- function(id) {
  tagList(
    fluidRow(
      column(
        width = 6,
        offset = 3,
        style = "padding-bottom: 100px",
        align = "left",
        br(),
        br(),

        h2("Get Engaged"),
        br(),

        # HTML("<p><span style='font-weight:bold'>Hints</span></p>"),
        HTML("<b>You found a typo or wrong content in one or multiple cells of the table? </b>"),
        br(),
        HTML("Please open an <i class='fa fa-github fa-lg'></i> <a href='https://github.com/MxNl/awesome_geodata_table/issues/new'>issue</a> with the tag 'content correction'"),
        br(),
        br(),
        HTML("<b>You want to improve the code or the functionality of <span style='font-family: Rubik Dirt; font-size:
          20px'>AwesomeGeodataTable</span>? </b>"),
        br(),
        HTML("Please open an <i class='fa fa-github fa-lg'></i> <a href='https://github.com/MxNl/awesome_geodata_table/issues/new'>issue</a> with the relevant tag"),
        br(),
        br(),
        HTML("<b>You have another question? </b>"),
        br(),
        HTML("<i class='fa fa-envelope fa-lg'></i>"),
        HTML("   awesomegeodatatable[at]gmail[dot]com"),
        br()
        #   tags$script(HTML(
        #     '<script>
        # /* 1. define variables */
        # var me = "max-n";
        # var place = "posteo.de";
        #
        # /* 2. find email link to replace */
        # var elink = document.getElementById("mlink");
        #
        # /* 3. replace link href with variables  */
        # elink.href = `mailto:${me}@${place}`;
        # </script>
        #
        # <a id="mlink" href="#">email me</a>'
        #   ))
        # tags$script(src = "mailto.js"),
      ),
    )
  )
}