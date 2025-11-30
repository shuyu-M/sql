# U.S. Airline Performance Analysis Website

A single-page data storytelling website analyzing over 636,000 domestic flights from May 2019, exploring patterns in delays, cancellations, and operational performance.

## 🚀 Quick Start

### Local Preview
```bash
quarto preview
```

### Build the Website
```bash
quarto render
```

The rendered website will be in the `docs/` folder.

## 📊 What's Inside

This website analyzes:
- **Maximum delays and early departures** by airline
- **Weekly flight patterns** and capacity utilization
- **Airport-specific delay challenges** 
- **Cancellation patterns** and root causes
- **Daily flight volume trends** with rolling averages

## 🎨 Features

- **Interactive visualizations** using Plotly
- **Responsive design** with clean, modern styling
- **Data-driven narrative** that goes beyond numbers
- **Collapsible code** for technical readers
- **Mobile-friendly** layout

## 📁 Project Structure

```
├── index.qmd              # Main content file
├── _quarto.yml           # Quarto configuration
├── styles.css            # Custom styling
├── docs/                 # Rendered website (GitHub Pages ready)
├── *.csv                 # SQL query results
└── *.sql                 # Original SQL queries
```

## 🌐 Publishing to GitHub Pages

Your GitHub Actions workflow is already configured! Just:

1. **Commit and push** your changes
2. **GitHub Actions will automatically** build and deploy
3. **Visit** your site at: `https://[username].github.io/[repo-name]`

Or manually deploy:
```bash
quarto publish gh-pages
```

## 🛠️ Technologies

- **Quarto**: Document publishing framework
- **Python**: Data analysis and visualization
- **Plotly**: Interactive charts
- **Pandas**: Data manipulation
- **GitHub Pages**: Hosting

## 📝 Customization

### Modify the Content
Edit `index.qmd` to change text, add sections, or update visualizations.

### Change Styling
Edit `styles.css` to customize colors, fonts, and layout.

### Update Configuration
Edit `_quarto.yml` to change theme, navigation, or output settings.

## 🎯 Key Insights

- Alaska Airlines had the lowest maximum delay (8.6 hours) vs American Airlines (28+ hours)
- Friday sees 59% more flights than Saturday
- Small regional airports face the highest average delays
- Weather drives 60%+ of cancellations at major airports
- Flight volume follows predictable weekly patterns with 20-30% weekend dips

---

**Data Source**: U.S. Department of Transportation, Bureau of Transportation Statistics (May 2019)
