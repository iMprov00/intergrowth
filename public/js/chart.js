function chartOptions(title, unit) {
  return {
    responsive: true,
    maintainAspectRatio: false,
    layout: {
      padding: {
        top: 30,
        right: 30,
        bottom: 30,
        left: 30
      }
    },
    plugins: {
      title: {
        display: true,
        text: title,
        font: {
          size: 20,
          weight: 'bold'
        },
        padding: {
          top: 10,
          bottom: 30
        }
      },
      legend: {
        position: 'top',
        labels: {
          font: {
            size: 14
          },
          padding: 20,
          boxWidth: 40
        }
      },
      tooltip: {
        bodyFont: {
          size: 14
        },
        padding: 12,
        displayColors: true,
        callbacks: {
          label: function(context) {
            return ` ${context.dataset.label}: ${context.parsed.y.toFixed(2)} ${unit}`;
          }
        }
      }
    },
    scales: {
      x: {
        title: {
          display: true,
          text: 'Гестационный возраст (недели)',
          font: {
            size: 16,
            weight: 'bold'
          },
          padding: { top: 20 }
        },
        ticks: {
          font: {
            size: 14
          }
        },
        grid: {
          display: false
        }
      },
      y: {
        title: {
          display: true,
          text: `${title} (${unit})`,
          font: {
            size: 16,
            weight: 'bold'
          },
          padding: { bottom: 20 }
        },
        ticks: {
          font: {
            size: 14
          },
          padding: 10
        },
        grid: {
          color: '#eaeaea',
          lineWidth: 2
        }
      }
    },
    elements: {
      point: {
        radius: 5,
        hoverRadius: 10,
        borderWidth: 2
      },
      line: {
        tension: 0.1,
        borderWidth: 2
      }
    }
  };
}