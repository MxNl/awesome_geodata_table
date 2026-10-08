my_csv2_download <- htmltools::tags$script(
  htmltools::HTML(
    "
      function mydownloadDataCSV(tableId, outfName = 'data.csv', colSep = ';', decSep = '.'){
        const data = Reactable.getState(tableId).data
        const headers = Object.keys(data[0]).join(colSep);
        const content = data.map(
          r => Object.values(r).map(
            c =>
              {if (typeof c === 'number') {
                return c.toString().replace('.', decSep);
              } else {
                return c;
        	}}).join(colSep));
        csv = [headers].concat(content).join('\\n');

        var blob = new Blob(['\uFEFF' + csv], { type: 'text/csv;charset=UTF-16;' });
        if (navigator.msSaveBlob) { // IE 10+
          navigator.msSaveBlob(blob, filename);
        } else {
          var link = document.createElement('a');
          if (link.download !== undefined) { // feature detection
            // Browsers that support HTML5 download attribute
            var url = URL.createObjectURL(blob);
            link.setAttribute('href', url);
            link.setAttribute('download', outfName);
            link.style.visibility = 'hidden';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
          }
        }
      }

      "
  )
)