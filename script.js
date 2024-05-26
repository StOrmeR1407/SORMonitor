google.charts.load('current', { packages: ['corechart', 'timeline'] });
$(document).ready(function () {
    $.post("api.aspx",
        {
        action : 'piechart',
        time: getCurrentDate()
    }
        , function (data) {
            var array = [];
            var j = JSON.parse(data);
            if (j.ok) {
                var data_chart = new google.visualization.DataTable();
                data_chart.addColumn('string', 'Name');
                data_chart.addColumn('number', 'Time');
                for (let i of j.datas) {
                    var name = i.name;
                    var time = i.time;
                    array.push([name, time]);
                }
                data_chart.addRows(array);

                // Set chart options
                var options = {
                    'title': 'Phân loại ứng dụng đã sử dụng trong tuần',
                    'width': 500,
                    'height': 500
                };

                // Instantiate and draw our chart, passing in some options.
                var chart = new google.visualization.PieChart(document.getElementById('summary_chart'));
                chart.draw(data_chart, options);
            }
            else {
                alert("Không có dữ liệu");
            }

        })

    $.post("api.aspx",
        {
            action: 'linechart_top5',
            time: getCurrentDate()
        }
        , function (data) {
            var array = [['Name', 'Time', { role: 'style' }]];
            var j = JSON.parse(data);
            if (j.ok) {             
                for (let i of j.datas) {
                    var name = i.name;
                    var time = i.time;
                    var style = '#b87333';
                    array.push([name, time, style]);
                }
                var data_chart = new google.visualization.arrayToDataTable(array);

                // Set chart options
                var options = {
                    'title': 'Top 5 ứng dụng dùng nhiều nhất trong tuần',
                    'width': 500,
                    'height': 500
                };

                // Instantiate and draw our chart, passing in some options.
                var chart = new google.visualization.ColumnChart(document.getElementById('top5_chart'));
                chart.draw(data_chart, options);
            }
            else {
                alert("Không có dữ liệu");
            }

        })

    $.post("api.aspx",
        {
            action: 'linechart_usedtime',
            time: getCurrentDate()
        }
        , function (data) {
            var array = [['Name', 'Time', { role: 'style' }]];
            var j = JSON.parse(data);
            if (j.ok) {
                for (let i of j.datas) {
                    var name = i.name;
                    var time = i.time;
                    var style = '#b87333';
                    array.push([name, time, style]);
                }
                var data_chart = new google.visualization.arrayToDataTable(array);

                // Set chart options
                var options = {
                    'title': 'Thời gian sử dụng trong tuần',
                    'width': 500,
                    'height': 500
                };

                // Instantiate and draw our chart, passing in some options.
                var chart = new google.visualization.ColumnChart(document.getElementById('usedtime_chart'));
                chart.draw(data_chart, options);
            }
            else {
                alert("Không có dữ liệu");
            }

        })
})

function getCurrentDate() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');

    return `${year}-${month}-${day}`;
}