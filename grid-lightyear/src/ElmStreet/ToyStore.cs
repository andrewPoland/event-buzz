using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Azure.WebJobs.Extensions.EventGrid;
using Microsoft.Azure.EventGrid.Models;
using ToyCollection;
using Microsoft.Extensions.Configuration;

namespace ElmStreet
{
    public static class ToyStore
    {
        [FunctionName("toy-store")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "post", Route = null)] HttpRequest req,
            [EventGrid(TopicEndpointUri = "MyEventGridTopicUriSetting", TopicKeySetting = "MyEventGridTopicKeySetting")]IAsyncCollector<EventGridEvent> outputEvents,            
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            int count = int.Parse( req.Query["eventcount"]);

            var toy = new BasicToy { 
                        Name = "Mr. Potato Head",
                        CatchPhrase = "You uncultured swine! What're you lookin' at, ya hockey puck?",
                        StaticPose = Pose.Standing
            };

            for(int i = 0; i < count; i++) { 
                await outputEvents.AddAsync( new EventGridEvent { 
                    Data = toy,
                    Topic = "evgt-abused-toys",
                    Subject = "new",
                    EventType = "toy-sold",
                    EventTime = DateTime.UtcNow,
                    DataVersion = "1.0",
                    Id = Guid.NewGuid().ToString()
                });

                // prevent exceeding event grid limits
                if(count > 1000) { 
                    await outputEvents.FlushAsync();
                    await Task.Delay(500);
                }
            }

            return new OkResult();
        }
    }
}
