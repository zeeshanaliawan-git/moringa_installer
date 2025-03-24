import React, { Component } from "react";
import { get as axiosGet } from "axios";
import AddRemoveLayout from "./AddRemoveLayout.jsx";

class GridDesigner extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      pageInfo: null
    };
  }

  componentDidMount() {
    if (pageId !== null) {
      let pageIdInput = document.getElementById("pageId");
      let pageId = "";
      if (pageIdInput) {
        pageId = pageIdInput.value;
        let url = "../pagesAjax.jsp";
        //url = "/page.json"; //debug
        axiosGet(url, {
          params: {
            requestType: "getPageInfo",
            pageId: pageId,
            rand: "" + Math.random()
          },
          dataType: "json"
        })
          .then(({ data }) => {
            const resp = data;
            if (resp.status == 1 && resp.data.page) {
              this.setState({ pageInfo: resp.data.page });
            } else {
              document.getElementById("infoMsg").innerHTML =
                '<span style="color: red;">Error in getting page info</span>';
            }
          })
          .catch(err => {
            document.getElementById("infoMsg").innerHTML =
              '<span style="color: red;">Error in getting page info</span>';
          })
          .finally(() => {});
      }
    }
  }

  /*
  componentWillUnmount() {
    //this.$el.somePlugin("destroy");
  } */

  render() {
    const pageInfo = this.state.pageInfo;
    let pageInfoLoaded = false;
    if (pageInfo !== null) {
      pageInfoLoaded = true;
    }
    return (
      <div className="w-100" ref={el => (this.el = el)}>
        {/* <div className="layout-str-container row">{this.printLayout()}</div> */}
        {pageInfoLoaded ? (
          <AddRemoveLayout
            // onLayoutChange={this.onLayoutChange}
            id="grid-designer"
            pageInfo={pageInfo}
          />
        ) : (
          <div id="infoMsg">
            <strong>Loading page info ...</strong>
          </div>
        )}
      </div>
    );
  }
}

export default GridDesigner;
